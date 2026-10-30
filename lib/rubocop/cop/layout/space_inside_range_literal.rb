# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside range literals.
      #
      # @example
      #   # bad
      #   1 .. 3
      #
      #   # good
      #   1..3
      #
      #   # bad
      #   'a' .. 'z'
      #
      #   # good
      #   'a'..'z'
      class SpaceInsideRangeLiteral < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Space inside range literal.'

        def on_irange(node)
          check(node)
        end

        def on_erange(node)
          check(node)
        end

        private

        def check(node)
          operator = node.loc.operator
          spaces = [space_before(node, operator), space_after(node, operator)].compact
          return if spaces.all? { |space| line_break_after_operator?(space, operator) }

          add_offense(node) do |corrector|
            spaces.each do |space|
              corrector.remove(space)
            end
          end
        end

        def space_before(node, operator)
          return unless node.begin

          whitespace_range(node.begin.source_range.end_pos, operator.begin_pos)
        end

        def space_after(node, operator)
          return unless node.end

          whitespace_range(operator.end_pos, node.end.source_range.begin_pos)
        end

        def line_break_after_operator?(space, operator)
          space.begin_pos == operator.end_pos && space.source.start_with?("\n")
        end

        def whitespace_range(begin_pos, end_pos)
          range = range_between(begin_pos, end_pos)

          range if range.source.match?(/\A\s+\z/)
        end
      end
    end
  end
end
