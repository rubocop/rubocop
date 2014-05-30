# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces the use the shorthand for self-assignment.
      #
      # @example
      #
      #   # bad
      #   x = x + 1
      #
      #   # good
      #   x += 1
      class SelfAssignment < Cop
        include AST::Sexp

        MSG = 'Use self-assignment shorthand `%s=`.'
        OPS = [:+, :-, :*, :**, :/, :|, :&]

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
          var_name, rhs = *node
          return unless rhs

          if rhs.type == :send
            check_send_node(node, rhs, var_name, var_type)
          elsif [:and, :or].include?(rhs.type)
            check_boolean_node(node, rhs, var_name, var_type)
          end
        end

        def check_send_node(node, rhs, var_name, var_type)
          receiver, method_name, *_args = *rhs
          return unless OPS.include?(method_name)

          target_node = s(var_type, var_name)
          return unless receiver == target_node

          add_offense(node, :expression, format(MSG, method_name))
        end

        def check_boolean_node(node, rhs, var_name, var_type)
          first_operand, _second_operand = *rhs

          target_node = s(var_type, var_name)
          return unless first_operand == target_node

          operator = rhs.loc.operator.source
          add_offense(node, :expression, format(MSG, operator))
        end
      end
    end
  end
end
