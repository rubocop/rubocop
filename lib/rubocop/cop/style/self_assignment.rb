# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of the shorthand for self-assignment.
      #
      # @example
      #
      #   # bad
      #   x = x + 1
      #
      #   # good
      #   x += 1
      class SelfAssignment < Base
        extend AutoCorrector

        MSG = 'Use self-assignment shorthand `%<method>s=`.'
        OPS = %i[+ - * ** / % ^ << >> | &].freeze

        def self.autocorrect_incompatible_with
          [Layout::SpaceAroundOperators]
        end

        def on_lvasgn(node)
          check(node, :lvar)
        end

        def on_ivasgn(node)
          check(node, :ivar)
        end

        def on_cvasgn(node)
          check(node, :cvar)
        end

        private

        def check(node, var_type)
          return unless (rhs = unparenthesized(node.expression))

          if rhs.send_type? && rhs.arguments.one?
            check_send_node(node, rhs, node.name, var_type)
          elsif rhs.operator_keyword? && rhs.logical_operator?
            check_boolean_node(node, rhs, node.name, var_type)
          end
        end

        def unparenthesized(node)
          node = node.children.first while node&.begin_type? && node.children.one?
          node
        end

        def check_send_node(node, rhs, var_name, var_type)
          return unless OPS.include?(rhs.method_name)

          target_node = s(var_type, var_name)
          return unless rhs.receiver == target_node

          add_offense(node, message: format(MSG, method: rhs.method_name)) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def check_boolean_node(node, rhs, var_name, var_type)
          target_node = s(var_type, var_name)
          return unless rhs.lhs == target_node

          operator = rhs.loc.operator.source
          add_offense(node, message: format(MSG, method: operator)) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def autocorrect(corrector, node)
          rhs = unparenthesized(node.expression)

          if rhs.send_type?
            apply_autocorrect(corrector, node, rhs.method_name, rhs.first_argument)
          elsif rhs.operator_keyword?
            apply_autocorrect(corrector, node, rhs.loc.operator.source, rhs.rhs)
          end
        end

        def apply_autocorrect(corrector, node, operator, new_rhs)
          corrector.insert_before(node.loc.operator, operator)
          corrector.replace(node.expression, new_rhs.source)
        end
      end
    end
  end
end
