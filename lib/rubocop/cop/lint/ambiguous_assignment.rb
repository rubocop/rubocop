# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for mistyped shorthand assignments.
      #
      # @example
      #   # bad
      #   x =- y
      #   x =+ y
      #   x =* y
      #   x =! y
      #
      #   # good
      #   x -= y # or x = -y
      #   x += y # or x = +y
      #   x *= y # or x = *y
      #   x != y # or x = !y
      #
      class AmbiguousAssignment < Base
        include CheckAssignment
        include RangeHelp

        MSG = 'Suspicious assignment detected. Did you mean `%<op>s`?'

        MISTAKES = { '=-' => '-=', '=+' => '+=', '=*' => '*=', '=!' => '!=' }.freeze

        alias on_csend on_send

        private

        def check_assignment(node, rhs)
          return unless rhs
          return unless (operator = node.loc.operator)

          range = range_between(operator.end_pos - 1, rhs.source_range.begin_pos + 1)
          source = range.source
          return unless MISTAKES.key?(source)

          add_offense(range, message: format(MSG, op: MISTAKES[source]))
        end
      end
    end
  end
end
