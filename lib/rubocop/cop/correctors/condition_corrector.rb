# frozen_string_literal: true

module RuboCop
  module Cop
    # This class does condition autocorrection
    class ConditionCorrector
      class << self
        include NegativeConditional

        def correct_negative_condition(corrector, node)
          condition = negated_condition(node)

          corrector.replace(node.loc.keyword, node.inverse_keyword)

          if single_negative?(condition)
            invert_condition(corrector, condition)
          else
            correct_chained_negatives(corrector, condition)
          end
        end

        private

        def negated_condition(node)
          condition = node.condition
          condition = condition.children.last while condition.begin_type?
          condition
        end

        def invert_condition(corrector, node)
          corrector.replace(node, node.children.first.source)
        end

        def correct_chained_negatives(corrector, condition)
          loop do
            corrector.replace(condition.loc.operator, condition.inverse_operator)

            invert_condition(corrector, condition.rhs)

            if single_negative?(condition.lhs)
              invert_condition(corrector, condition.lhs)
              return
            end

            condition = condition.lhs
          end
        end
      end
    end
  end
end
