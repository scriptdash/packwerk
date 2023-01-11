# typed: strict
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    class ReferenceChecker
      extend T::Sig

      sig { params(checkers: T::Array[Checkers::Checker], reference_collector: ReferenceCollector).void }
      def initialize(checkers, reference_collector = NoOpReferenceCollector.new)
        @checkers = checkers
        @reference_collector = reference_collector
      end

      sig do
        params(
          reference: Reference
        ).returns(T::Array[Packwerk::Offense])
      end
      def call(reference)
        @checkers.each_with_object([]) do |checker, violations|
          invalid_reference = checker.invalid_reference?(reference)
          collect_reference(reference, invalid_reference, checker)

          next unless invalid_reference

          offense = Packwerk::ReferenceOffense.new(
            location: reference.source_location,
            reference: reference,
            violation_type: checker.violation_type,
            message: checker.message(reference)
          )
          violations << offense
        end
      end

      private

      sig do
        params(
          reference: Reference,
          invalid_reference: T::Boolean,
          checker: Checkers::Checker,
        ).void
      end
      def collect_reference(reference, invalid_reference, checker)
        if invalid_reference
          @reference_collector.collect_invalid(reference: reference, violation_type: checker.violation_type)
        else
          @reference_collector.collect_valid(reference: reference, violation_type: checker.violation_type)
        end
      end
    end
  end
end
