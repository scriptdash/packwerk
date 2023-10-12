# typed: strict
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    module Checkers
      module Checker
        extend T::Sig
        extend T::Helpers

        abstract!

        sig { abstract.returns(String) }
        def violation_type; end

        sig { abstract.params(reference: Reference).returns(T::Boolean) }
        def invalid_reference?(reference); end

        sig { abstract.params(reference: Reference).returns(T.nilable(String)) }
        def violation_level(reference)
          nil
        end

        sig { abstract.params(reference: Reference).returns(String) }
        def message(reference); end

        sig { params(reference: Reference).returns(String) }
        def standard_help_message(reference)
          standard_message = <<~EOS
            Inference details: this is a reference to #{reference.constant.name} which seems to be defined in #{reference.constant.location}.
            To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
          EOS

          standard_message.chomp
        end
      end
    end
  end
end
