# typed: strict
# frozen_string_literal: true

module Packwerk
  class ReferenceCollector
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(reference: Reference, violation_type: String).void }
    def collect_invalid(reference:, violation_type:); end

    sig { abstract.params(reference: Reference, violation_type: String).void }
    def collect_valid(reference:, violation_type:); end
  end
end
