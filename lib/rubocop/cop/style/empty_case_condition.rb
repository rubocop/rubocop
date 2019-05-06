# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for case statements with an empty condition.
      #
      # @example
      #
      #   # bad:
      #   case
      #   when x == 0
      #     puts 'x is 0'
      #   when y == 0
      #     puts 'y is 0'
      #   else
      #     puts 'neither is 0'
      #   end
      #
      #   # good:
      #   if x == 0
      #     puts 'x is 0'
      #   elsif y == 0
      #     puts 'y is 0'
      #   else
      #     puts 'neither is 0'
      #   end
      #
      #   # good: (the case condition node is not empty)
      #   case n
      #   when 0
      #     puts 'zero'
      #   when 1
      #     puts 'one'
      #   else
      #     puts 'more'
      #   end
      class EmptyCaseCondition < Cop
        include RangeHelp

        MSG = 'Do not use empty `case` condition, instead use an `if` '\
              'expression.'

        def on_case(case_node)
          return if case_node.condition
          return if case_node.when_branches.any? do |when_branch|
            when_branch.each_descendant.any?(&:return_type?)
          end

          if (else_branch = case_node.else_branch)
            return if else_branch.return_type? ||
                      else_branch.each_descendant.any?(&:return_type?)
          end

          add_offense(case_node, location: :keyword)
        end

        def autocorrect(case_node)
          when_branches = case_node.when_branches

          lambda do |corrector|
            correct_case_when(corrector, case_node, when_branches)
            correct_when_conditions(corrector, when_branches)
          end
        end

        private

        def correct_case_when(corrector, case_node, when_nodes)
          case_range = case_node.loc.keyword.join(when_nodes.first.loc.keyword)

          corrector.replace(case_range, 'if')

          keep_first_when_comment(case_node, when_nodes.first, corrector)

          when_nodes[1..-1].each do |when_node|
            corrector.replace(when_node.loc.keyword, 'elsif')
          end
        end

        def correct_when_conditions(corrector, when_nodes)
          when_nodes.each do |when_node|
            conditions = when_node.conditions

            next unless conditions.size > 1

            range = range_between(conditions.first.loc.expression.begin_pos,
                                  conditions.last.loc.expression.end_pos)

            corrector.replace(range, conditions.map(&:source).join(' || '))
          end
        end

        def keep_first_when_comment(case_node, first_when_node, corrector)
          comment = processed_source.comments_before_line(
            first_when_node.loc.keyword.line
          ).map(&:text).join("\n")

          line = range_by_whole_lines(case_node.source_range)

          corrector.insert_before(line, "#{comment}\n") if !comment.empty? &&
                                                           !case_node.parent
        end
      end
    end
  end
end
