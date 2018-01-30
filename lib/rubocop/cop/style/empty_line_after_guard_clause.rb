# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces empty line after guard clause
      #
      # @example
      #
      #   # bad
      #   def foo
      #     return if need_return?
      #     bar
      #   end
      #
      #   # good
      #   def foo
      #     return if need_return?
      #
      #     bar
      #   end
      #
      #   # good
      #   def foo
      #     if something?
      #       do_something
      #       return if need_return?
      #     end
      #   end
      class EmptyLineAfterGuardClause < Cop
        include RangeHelp

        MSG = 'Add empty line after guard clause.'.freeze

        def on_if(node)
          return unless contains_guard_clause?(node)

          if node.parent
            return if node.parent.single_line?
            return if next_sibling_guard_clause?(node)
          end

          return if next_line_empty?(node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            node_range = range_by_whole_lines(node.source_range)
            corrector.insert_after(node_range, "\n")
          end
        end

        private

        def next_sibling_guard_clause?(node)
          next_sibling = node.parent.children[node.sibling_index + 1]
          return false if next_sibling.nil?

          next_sibling.if_type? && contains_guard_clause?(next_sibling)
        end

        def next_line_empty?(node)
          next_line = processed_source[node.last_line]

          line_end?(next_line) || next_line.blank?
        end

        def line_end?(line)
          line =~ /^\s*end/
        end

        def contains_guard_clause?(node)
          node.if_branch && node.if_branch.guard_clause?
        end
      end
    end
  end
end
