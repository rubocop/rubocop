# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
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

        MSG = 'Add empty line after guard clause.'
        END_OF_HEREDOC_LINE = 1

        def on_if(node)
          return if correct_style?(node)

          if node.modifier_form? && last_argument_is_heredoc?(node)
            heredoc_node = last_heredoc_argument(node)

            return if next_line_empty?(heredoc_line(node, heredoc_node))

            add_offense(heredoc_node, location: :heredoc_end)
          else
            return if next_line_empty?(node.last_line)

            add_offense(node, location: offense_location(node))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            node_range = if node.respond_to?(:heredoc?) && node.heredoc?
                           range_by_whole_lines(node.loc.heredoc_body)
                         else
                           range_by_whole_lines(node.source_range)
                         end

            corrector.insert_after(node_range, "\n")
          end
        end

        private

        def correct_style?(node)
          !contains_guard_clause?(node) ||
            next_line_rescue_or_ensure?(node) ||
            next_sibling_parent_empty_or_else?(node) ||
            next_sibling_empty_or_guard_clause?(node)
        end

        def contains_guard_clause?(node)
          node.if_branch&.guard_clause?
        end

        def next_line_empty?(line)
          processed_source[line].blank?
        end

        def next_line_rescue_or_ensure?(node)
          parent = node.parent
          parent.nil? || parent.rescue_type? || parent.ensure_type?
        end

        def next_sibling_parent_empty_or_else?(node)
          next_sibling = node.parent.children[node.sibling_index + 1]
          return true if next_sibling.nil?

          parent = next_sibling.parent

          parent&.if_type? && parent&.else?
        end

        def next_sibling_empty_or_guard_clause?(node)
          next_sibling = node.parent.children[node.sibling_index + 1]
          return true if next_sibling.nil?

          next_sibling.if_type? && contains_guard_clause?(next_sibling)
        end

        def last_argument_is_heredoc?(node)
          last_children = node.if_branch
          return false unless last_children&.send_type?

          heredoc?(last_heredoc_argument(node))
        end

        def last_heredoc_argument(node)
          n = if node.respond_to?(:if_branch)
                node.if_branch.children.last
              else
                node
              end

          return n if heredoc?(n)
          return unless n.respond_to?(:arguments)

          n.arguments.each do |argument|
            node = last_heredoc_argument(argument)
            return node if node
          end

          return last_heredoc_argument(n.receiver) if n.respond_to?(:receiver)
        end

        def heredoc_line(node, heredoc_node)
          heredoc_body = heredoc_node.loc.heredoc_body
          num_of_heredoc_lines =
            heredoc_body.last_line - heredoc_body.first_line

          node.last_line + num_of_heredoc_lines + END_OF_HEREDOC_LINE
        end

        def heredoc?(node)
          node.respond_to?(:heredoc?) && node.heredoc?
        end

        def offense_location(node)
          if node.loc.respond_to?(:end) && node.loc.end
            :end
          else
            :expression
          end
        end
      end
    end
  end
end
