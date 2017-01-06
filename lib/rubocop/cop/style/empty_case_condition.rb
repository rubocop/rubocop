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
        MSG = 'Do not use empty `case` condition, instead use an `if` '\
              'expression.'.freeze

        def on_case(case_node)
          return if case_node.condition

          add_offense(case_node, :keyword, MSG)
        end

        private

        def autocorrect(case_node)
          when_branches = case_node.when_branches

          lambda do |corrector|
            correct_case_when(corrector, case_node, when_branches)
            correct_when_conditions(corrector, when_branches)
          end
        end

        def correct_case_when(corrector, case_node, when_nodes)
          case_range = case_node.loc.keyword.join(when_nodes.shift.loc.keyword)

          corrector.replace(case_range, 'if')

          when_nodes.each do |when_node|
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
      end
    end
  end
end
