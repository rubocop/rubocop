# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for ambiguous regexp literals in the first argument of
      # a method invocation without parentheses.
      #
      # @example
      #
      #   # bad
      #
      #   # This is interpreted as a method invocation with a regexp literal,
      #   # but it could possibly be `/` method invocations.
      #   # (i.e. `do_something./(pattern)./(i)`)
      #   do_something /pattern/i
      #
      # @example
      #
      #   # good
      #
      #   # With parentheses, there's no ambiguity.
      #   do_something(/pattern/i)
      class AmbiguousRegexpLiteral < Cop
        include ParserDiagnostic

        MSG = 'Ambiguous regexp literal. Parenthesize the method arguments ' \
              "if it's surely a regexp literal, or add a whitespace to the " \
              'right of the `/` if it should be a division.'.freeze

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :ambiguous_literal
        end

        def alternative_message(_diagnostic)
          MSG
        end
      end
    end
  end
end
