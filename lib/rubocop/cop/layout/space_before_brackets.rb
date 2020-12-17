# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for space between the name of a receiver and a left
      # brackets.
      #
      # This cop is marked as unsafe because it can occur false positives
      # for `do_something [this_is_an_array_literal_argument]` that take
      # an array without parentheses as an argument.
      #
      # @example
      #
      #   # bad
      #   collection [index_or_key]
      #
      #   # good
      #   collection[index_or_key]
      #
      class SpaceBeforeBrackets < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove the space before the opening brackets.'

        def on_send(node)
          return if node.parenthesized? || node.parent&.send_type?
          return unless (first_argument = node.first_argument)

          begin_pos = first_argument.source_range.begin_pos

          return unless (range = offense_range(node, first_argument, begin_pos))

          register_offense(range)
        end

        private

        def offense_range(node, first_argument, begin_pos)
          if space_before_brackets?(node, first_argument)
            range_between(node.loc.selector.end_pos, begin_pos)
          elsif node.method?(:[]=)
            end_pos = node.receiver.source_range.end_pos

            return if begin_pos - end_pos == 1

            range_between(end_pos, begin_pos - 1)
          end
        end

        def register_offense(range)
          add_offense(range) do |corrector|
            corrector.remove(range)
          end
        end

        def space_before_brackets?(node, first_argument)
          node.receiver.nil? && first_argument.array_type? && node.arguments.size == 1
        end
      end
    end
  end
end
