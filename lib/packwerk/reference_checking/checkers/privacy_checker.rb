# typed: strict
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    module Checkers
      # Checks whether a given reference references a private constant of another package.
      class PrivacyChecker
        extend ActiveSupport::Autoload
        autoload :PrivacyProtectedPackage

        extend T::Sig
        include Packwerk::Checker

        VIOLATION_TYPE = T.let("privacy", String)

        sig { override.returns(String) }
        def violation_type
          VIOLATION_TYPE
        end

        sig do
          override
            .params(reference: Packwerk::Reference)
            .returns(T::Boolean)
        end
        def invalid_reference?(reference)
          return false if reference.constant.public?

          privacy_option = reference.constant.package.enforce_privacy

          return false if enforcement_disabled?(privacy_option) ||
            explicitly_private_constant?(reference.constant, explicitly_private_constants: reference.constant.package.explicitly_private_constants)

          return false if explicitly_public_constant?(
            reference.constant, explicitly_public_constants: reference.constant.package.public_constants
          )

          true
        end

        sig { override.params(offense: ReferenceOffense).returns(T.nilable(String)) }
        def violation_level(offense)
          offense.reference.constant.package.enforce_privacy.to_s
        end

        sig do
          override
            .params(reference: Packwerk::Reference)
            .returns(String)
        end
        def message(reference)
          source_desc = "'#{reference.source_package}'"

          message = <<~EOS
            Privacy violation: '#{reference.constant.name}' is private to '#{reference.constant.package}' but referenced from #{source_desc}.
            Is there a public entrypoint from any of the following constants that you can use instead?
            --> '#{reference.constant.package.public_constants.join(', ')}'

            #{standard_help_message(reference)}
          EOS

          message.chomp
        end

        private

        sig do
          params(
            constant: ConstantDiscovery::ConstantContext,
            explicitly_public_constants: T::Array[String]
          ).returns(T::Boolean)
        end
        def explicitly_public_constant?(constant, explicitly_public_constants:)
          explicitly_public_constants.include?(constant.name)
        end

        sig do
          params(
            constant: ConstantDiscovery::ConstantContext,
            explicitly_private_constants: T::Array[String]
          ).returns(T::Boolean)
        end
        def explicitly_private_constant?(constant, explicitly_private_constants:)
          explicitly_private_constants.include?(constant.name) ||
            # nested constants
            explicitly_private_constants.any? { |epc| constant.name.start_with?(epc + "::") }
        end

        sig do
          params(privacy_option: T.nilable(T.any(T::Boolean, String)))
            .returns(T::Boolean)
        end
        def enforcement_disabled?(privacy_option)
          [false, nil].include?(privacy_option)
        end
      end
    end
  end
end
