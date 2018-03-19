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
      #     return if something?
      #     return if something_different?
      #
      #     bar
      #   end
      #
      #   # also good
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
          return if correct_style?(node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            node_range = range_by_whole_lines(node.source_range)
            corrector.insert_after(node_range, "\n")
          end
        end

        private

        def correct_style?(node)
          !contains_guard_clause?(node) ||
            next_line_rescue_or_ensure?(node) ||
            next_sibling_parent_empty_or_else?(node) ||
            next_sibling_empty_or_guard_clause?(node) ||
            last_argument_is_heredoc?(node) ||
            next_line_empty?(node)
        end

        def contains_guard_clause?(node)
          node.if_branch && node.if_branch.guard_clause?
        end

        def next_line_empty?(node)
          processed_source[node.last_line].blank?
        end

        def next_line_rescue_or_ensure?(node)
          parent = node.parent
          parent.nil? || parent.rescue_type? || parent.ensure_type?
        end

        def next_sibling_parent_empty_or_else?(node)
          next_sibling = node.parent.children[node.sibling_index + 1]
          return true if next_sibling.nil?

          parent = next_sibling.parent

          parent && parent.if_type? && parent.else?
        end

        def next_sibling_empty_or_guard_clause?(node)
          next_sibling = node.parent.children[node.sibling_index + 1]
          return true if next_sibling.nil?

          next_sibling.if_type? && contains_guard_clause?(next_sibling)
        end

        def last_argument_is_heredoc?(node)
          node.children.last && node.children.last.send_type? &&
            node.children.last.last_argument.heredoc?
        end
      end
    end
  end
end
