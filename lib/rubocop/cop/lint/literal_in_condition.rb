# encoding: utf-8

module Rubocop
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
        MSG = 'Literal %s appeared in a condition.'

        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false]

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

        def message(node)
          MSG.format(node.loc.expression.source)
        end

        private

        def check_for_literal(node)
          cond, = *node

          # if the cond node is literal we obviously have a problem
          if literal?(cond)
            add_offence(cond, :expression)
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

        def literal?(node)
          LITERALS.include?(node.type)
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
          if literal?(node)
            add_offence(node, :expression)
          elsif [:send, :and, :or, :begin].include?(node.type)
            check_node(node)
          end
        end
      end
    end
  end
end
