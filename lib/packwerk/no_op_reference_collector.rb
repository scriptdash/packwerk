# typed: strict
# frozen_string_literal: true

module Packwerk
  class NoOpReferenceCollector < ReferenceCollector
    extend T::Sig

    sig { override.params(reference: Reference, violation_type: String).void }
    def collect_invalid(reference:, violation_type:); end

    sig { override.params(reference: Reference, violation_type: String).void }
    def collect_valid(reference:, violation_type:); end
  end
end
