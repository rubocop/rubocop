# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for else branches of if statements that skip the rest of the loop or exit it.
      #
      # @example
      #
      #   # bad
      #   if condition
      #    foo
      #    next
      #   else
      #     bar
      #   end
      #
      #   # good
      #   if condition
      #    foo
      #    next
      #   end
      #
      #   bar
      #
      class RedundantElse < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'This condition is redundant because the if statement skips the rest of the loop.'

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        def on_block(node)
          return unless node.enumerable_method? || node.enumerator_method?

          statements(node).each do |node|
            next unless node.if_type? && node.else?

            next if node.if_branch.each_child_node(:return, :next, :break).reject do |node|
              node.parent.if_type?
            end.to_a.empty?

            add_offense(node.loc.else) do |corrector|
              corrector.replace(node.loc.else, "end\n")
              corrector.remove(range_by_whole_lines(node.loc.end, include_final_newline: true))
            end
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
        alias on_numblock on_block

        private

        def statements(node)
          node.body.begin_type? ? node.body.children : [node.body]
        end
      end
    end
  end
end
