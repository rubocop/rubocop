# frozen_string_literal: true

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
        MSG = 'Use self-assignment shorthand `%<method>s=`.'
        OPS = %i[+ - * ** / | &].freeze

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

        def autocorrect(node)
          _var_name, rhs = *node

          if rhs.send_type?
            autocorrect_send_node(node, rhs)
          elsif %i[and or].include?(rhs.type)
            autocorrect_boolean_node(node, rhs)
          end
        end

        private

        def check(node, var_type)
          var_name, rhs = *node
          return unless rhs

          if rhs.send_type?
            check_send_node(node, rhs, var_name, var_type)
          elsif %i[and or].include?(rhs.type)
            check_boolean_node(node, rhs, var_name, var_type)
          end
        end

        def check_send_node(node, rhs, var_name, var_type)
          receiver, method_name, *_args = *rhs
          return unless OPS.include?(method_name)

          target_node = s(var_type, var_name)
          return unless receiver == target_node

          add_offense(node, message: format(MSG, method: method_name))
        end

        def check_boolean_node(node, rhs, var_name, var_type)
          first_operand, _second_operand = *rhs

          target_node = s(var_type, var_name)
          return unless first_operand == target_node

          operator = rhs.loc.operator.source
          add_offense(node, message: format(MSG, method: operator))
        end

        def autocorrect_send_node(node, rhs)
          _receiver, method_name, args = *rhs
          apply_autocorrect(node, rhs, method_name.to_s, args)
        end

        def autocorrect_boolean_node(node, rhs)
          _first_operand, second_operand = *rhs
          apply_autocorrect(node, rhs, rhs.loc.operator.source, second_operand)
        end

        def apply_autocorrect(node, rhs, operator, new_rhs)
          lambda do |corrector|
            corrector.insert_before(node.loc.operator, operator)
            corrector.replace(rhs.source_range, new_rhs.source)
          end
        end
      end
    end
  end
end
