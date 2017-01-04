# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks that there are no repeated conditions
      # used in case 'when' expressions.
      #
      # @example
      #
      #   # bad
      #
      #   case x
      #   when 'first'
      #     do_something
      #   when 'first'
      #     do_something_else
      #   end
      #
      # @example
      #
      #   # good
      #
      #   case x
      #   when 'first
      #     do_something
      #   when 'second'
      #     do_something_else
      #   end
      class DuplicateCaseCondition < Cop
        MSG = 'Duplicate `when` condition detected.'.freeze

        def on_case(case_node)
          conditions_seen = []

          case_node.when_branches.each do |when_node|
            conditions = when_conditions(when_node)
            conditions.each do |cond|
              if repeated_condition?(conditions_seen, cond)
                add_offense(case_node, cond.loc.expression, MSG)
              end
            end
            conditions_seen.push(conditions)
          end
        end

        private

        def when_conditions(when_node)
          when_node.to_a[0...-1]
        end

        def repeated_condition?(conditions_seen, condition)
          conditions_seen.any? { |x| x.include?(condition) }
        end
      end
    end
  end
end
