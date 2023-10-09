# typed: strict
# frozen_string_literal: true

# Optionally do not consider offenses as violations.
module Packwerk
  class ViolationFilter
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(reference: Reference).returns(T::Boolean) }
    def ignore_violation?(reference)
    end
  end
end
