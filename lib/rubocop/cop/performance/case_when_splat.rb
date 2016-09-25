# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Place `when` conditions that use splat at the end
      # of the list of `when` branches.
      #
      # Ruby has to allocate memory for the splat expansion every time
      # that the `case` `when` statement is run. Since Ruby does not support
      # fall through inside of `case` `when`, like some other languages do,
      # the order of the `when` branches does not matter. By placing any
      # splat expansions at the end of the list of `when` branches we will
      # reduce the number of times that memory has to be allocated for
      # the expansion.
      #
      # This is not a guaranteed performance improvement. If the data being
      # processed by the `case` condition is normalized in a manner that favors
      # hitting a condition in the splat expansion, it is possible that
      # moving the splat condition to the end will use more memory,
      # and run slightly slower.
      #
      # @example
      #   # bad
      #   case foo
      #   when *condition
      #     bar
      #   when baz
      #     foobar
      #   end
      #
      #   case foo
      #   when *[1, 2, 3, 4]
      #     bar
      #   when 5
      #     baz
      #   end
      #
      #   # good
      #   case foo
      #   when baz
      #     foobar
      #   when *condition
      #     bar
      #   end
      #
      #   case foo
      #   when 1, 2, 3, 4
      #     bar
      #   when 5
      #     baz
      #   end
      class CaseWhenSplat < Cop
        include AutocorrectAlignment

        MSG = 'Place `when` conditions with a splat ' \
              'at the end of the `when` branches.'.freeze
        ARRAY_MSG = 'Do not expand array literals in `when` conditions.'.freeze
        PERCENT_W = '%w'.freeze
        PERCENT_CAPITAL_W = '%W'.freeze
        PERCENT_I = '%i'.freeze
        PERCENT_CAPITAL_I = '%I'.freeze

        def on_case(node)
          _case_branch, *when_branches, _else_branch = *node
          when_conditions =
            when_branches.each_with_object([]) do |branch, conditions|
              *condition, _ = *branch
              condition.each { |c| conditions << c }
            end

          splat_offenses(when_conditions).reverse_each do |condition|
            range = condition.parent.loc.keyword.join(condition.source_range)
            variable, = *condition
            message = variable.array_type? ? ARRAY_MSG : MSG
            add_offense(condition.parent, range, message)
          end
        end

        def autocorrect(node)
          *conditions, _body = *node

          lambda do |corrector|
            if needs_reorder?(conditions)
              reorder_condition(corrector, node, replacement(conditions))
            else
              inline_fix_branch(corrector, node, conditions,
                                replacement(conditions))
            end
          end
        end

        private

        def replacement(conditions)
          new_condition = conditions.map(&:source)
          new_condition.join(', ')
        end

        def inline_fix_branch(corrector, _node, conditions, new_condition)
          range = range_between(conditions[0].loc.expression.begin_pos,
                                conditions[-1].loc.expression.end_pos)
          corrector.replace(range, new_condition)
        end

        def reorder_condition(corrector, node, new_condition)
          *_conditions, body = *node
          _case_branch, *when_branches, _else_branch = *node.parent
          corrector.remove(when_branch_range(node, when_branches))

          correction = if same_line?(node, body)
                         new_condition_with_then(node, new_condition)
                       else
                         new_branch_without_then(node, body, new_condition)
                       end

          corrector.insert_after(when_branches.last.source_range, correction)
        end

        def when_branch_range(node, when_branches)
          current_index = when_branches.index { |branch| branch == node }
          next_branch = when_branches[current_index + 1]

          range_between(node.source_range.begin_pos,
                        next_branch.source_range.begin_pos)
        end

        def same_line?(node, other)
          node.loc.first_line == other.loc.first_line
        end

        def new_condition_with_then(node, new_condition)
          "\n#{' ' * node.loc.column}when " \
            "#{new_condition} then #{node.children.last.source}"
        end

        def new_branch_without_then(node, body, new_condition)
          "\n#{' ' * node.loc.column}when #{new_condition}\n" \
            "#{' ' * body.loc.column}#{node.children.last.source}"
        end

        def splat_offenses(when_conditions)
          found_non_splat = false
          when_conditions.reverse.each_with_object([]) do |condition, result|
            found_non_splat ||= error_condition?(condition)

            next unless condition.splat_type?
            variable, = *condition
            next if variable.array_type?
            result << condition if found_non_splat
          end
        end

        def error_condition?(condition)
          variable, = *condition

          (condition.splat_type? && variable.array_type?) ||
            !condition.splat_type?
        end

        def needs_reorder?(conditions)
          conditions.any? do |condition|
            variable, = *condition
            condition.splat_type? && !(variable && variable.array_type?)
          end
        end
      end
    end
  end
end
