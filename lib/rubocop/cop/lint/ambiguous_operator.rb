# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for ambiguous operators in the first argument of a
      # method invocation without parentheses.
      #
      # @example
      #   array = [1, 2, 3]
      #
      #   # The `*` is interpreted as a splat operator but it could possibly be
      #   # a `*` method invocation (i.e. `do_something.*(array)`).
      #   do_something *array
      #
      #   # With parentheses, there's no ambiguity.
      #   do_something(*array)
      class AmbiguousOperator < Cop
        include ParserDiagnostic

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :ambiguous_prefix
        end
      end
    end
  end
end
