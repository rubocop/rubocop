# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for literals used as the conditions or as
      # operands in and/or expressions serving as the conditions of
      # if/while/until.
      #
      # @example
      #
      #   if 20
      #     do_something
      #   end
      #
      #   if some_var && true
      #     do_something
      #   end
      #
      class LiteralInCondition < Cop
        MSG = 'Literal `%s` appeared in a condition.'.freeze

        def on_if(node)
          check_for_literal(node)
        end

        def on_while(node)
          check_for_literal(node)
        end

        def on_while_post(node)
          check_for_literal(node)
        end

        def on_until(node)
          check_for_literal(node)
        end

        def on_until_post(node)
          check_for_literal(node)
        end

        def on_case(node)
          cond, *whens, _else = *node

          if cond
            check_case_cond(cond)
          else
            whens.each do |when_node|
              check_for_literal(when_node)
            end
          end
        end

        def message(node)
          format(MSG, node.source)
        end

        private

        def check_for_literal(node)
          cond, = *node

          # if the cond node is literal we obviously have a problem
          if cond.literal?
            add_offense(cond, :expression)
          else
            # alternatively we have to consider a logical node with a
            # literal argument
            check_node(cond)
          end
        end

        def not?(node)
          return false unless node && node.type == :send

          _receiver, method_name, *_args = *node

          method_name == :!
        end

        def basic_literal?(node)
          if node && node.type == :array
            primitive_array?(node)
          else
            node.basic_literal?
          end
        end

        def primitive_array?(node)
          node.children.all? { |n| basic_literal?(n) }
        end

        def check_node(node)
          return unless node

          if not?(node)
            receiver, = *node

            handle_node(receiver)
          elsif [:and, :or].include?(node.type)
            *operands = *node
            operands.each do |op|
              handle_node(op)
            end
          elsif node.type == :begin && node.children.size == 1
            child_node = node.children.first
            handle_node(child_node)
          end
        end

        def handle_node(node)
          if node.literal?
            add_offense(node, :expression)
          elsif [:send, :and, :or, :begin].include?(node.type)
            check_node(node)
          end
        end

        def check_case_cond(node)
          return if node.type == :array && !primitive_array?(node)
          return if node.type == :dstr

          handle_node(node)
        end
      end
    end
  end
end
