# typed: strict
# frozen_string_literal: true

module Packwerk
  class ReferenceCollector
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(reference: Reference, violation_type: String, valid: T::Boolean).void }
    def collect_reference(reference:, violation_type:, valid:); end

    sig { overridable.void }
    def stop; end
  end
end
