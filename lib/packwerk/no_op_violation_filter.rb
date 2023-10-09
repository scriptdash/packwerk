# typed: strict
# frozen_string_literal: true

module Packwerk
  class NoOpViolationFilter < ViolationFilter
    extend T::Sig

    sig { override.params(reference: Reference).returns(T::Boolean) }
    def ignore_violation?(reference)
      false
    end
  end
end
