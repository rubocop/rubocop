# encoding: utf-8

module Rubocop
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

        OPS = [:+, :-, :*, :**, :/]

        def on_lvasgn(node)
          check(node, :lvar)
        end

        def on_ivasgn(node)
          check(node, :ivar)
        end

        def on_cvasgn(node)
          check(node, :cvar)
        end

        def check(node, var_type)
          var_name, rhs = *node

          return unless rhs && rhs.type == :send

          receiver, method_name, *_args = *rhs

          return unless OPS.include?(method_name)

          target_node = s(var_type, var_name)

          if receiver == target_node
            add_offense(node,
                        :expression,
                        "Use self-assignment shorthand #{method_name}=.")
          end
        end
      end
    end
  end
end
