# typed: strict
# frozen_string_literal: true

module Packwerk
  class NoOpReferenceCollector < ReferenceCollector
    extend T::Sig

    sig { override.params(reference: Reference, violation_type: String, valid: T::Boolean).void }
    def collect_reference(reference:, violation_type:, valid:); end
  end
end
