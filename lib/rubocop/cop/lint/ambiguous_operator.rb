# encoding: utf-8
# frozen_string_literal: true

module RuboCop
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

        AMBIGUITIES = {
          '+'  => { actual: 'positive number', possible: 'addition' },
          '-'  => { actual: 'negative number', possible: 'subtraction' },
          '*'  => { actual: 'splat',           possible: 'multiplication' },
          '&'  => { actual: 'block',           possible: 'binary AND' },
          '**' => { actual: 'keyword splat',   possible: 'exponent' }
        }.each do |key, hash|
          hash[:operator] = key
        end

        MSG_FORMAT = 'Ambiguous %{actual} operator. Parenthesize the method ' \
                     "arguments if it's surely a %{actual} operator, or add " \
                     'a whitespace to the right of the `%{operator}` if it ' \
                     'should be a %{possible}.'.freeze

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
