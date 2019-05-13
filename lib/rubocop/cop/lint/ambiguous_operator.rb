# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for ambiguous operators in the first argument of a
      # method invocation without parentheses.
      #
      # @example
      #
      #   # bad
      #
      #   # The `*` is interpreted as a splat operator but it could possibly be
      #   # a `*` method invocation (i.e. `do_something.*(some_array)`).
      #   do_something *some_array
      #
      # @example
      #
      #   # good
      #
      #   # With parentheses, there's no ambiguity.
      #   do_something(*some_array)
      class AmbiguousOperator < Cop
        include ParserDiagnostic

        AMBIGUITIES = {
          '+'  => { actual: 'positive number', possible: 'addition' },
          '-'  => { actual: 'negative number', possible: 'subtraction' },
          '*'  => { actual: 'splat',           possible: 'multiplication' },
          '&'  => { actual: 'block',           possible: 'binary AND' },
          '**' => { actual: 'keyword splat',   possible: 'exponent' }
        }.each do |key, hash|
          hash[:operator] = key
        end

        MSG_FORMAT = 'Ambiguous %<actual>s operator. Parenthesize the method ' \
                     "arguments if it's surely a %<actual>s operator, or add " \
                     'a whitespace to the right of the `%<operator>s` if it ' \
                     'should be a %<possible>s.'

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :ambiguous_prefix
        end

        def alternative_message(diagnostic)
          operator = diagnostic.location.source
          hash = AMBIGUITIES[operator]
          format(MSG_FORMAT, hash)
        end
      end
    end
  end
end
