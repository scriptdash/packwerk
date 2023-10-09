# typed: strict
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    class ReferenceChecker
      extend T::Sig

      sig do
        params(
          checkers: T::Array[Checkers::Checker],
          reference_collector: ReferenceCollector,
          violation_filter: ViolationFilter,
        ).void
      end
      def initialize(
        checkers,
        reference_collector = NoOpReferenceCollector.new,
        violation_filter = NoOpViolationFilter.new
      )
        @checkers = checkers
        @reference_collector = reference_collector
        @violation_filter = violation_filter
      end

      sig do
        params(
          reference: Reference
        ).returns(T::Array[Packwerk::Offense])
      end
      def call(reference)
        @checkers.each_with_object([]) do |checker, violations|
          invalid_reference = checker.invalid_reference?(reference)
          @reference_collector.collect_reference(
            reference: reference,
            violation_type: checker.violation_type,
            valid: !invalid_reference,
          )

          next unless invalid_reference
          next if @violation_filter.ignore_violation?(reference)

          offense = Packwerk::ReferenceOffense.new(
            location: reference.source_location,
            reference: reference,
            violation_type: checker.violation_type,
            message: checker.message(reference)
          )
          violations << offense
        end
      end
    end
  end
end
