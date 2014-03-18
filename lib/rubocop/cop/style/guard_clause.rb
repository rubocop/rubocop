# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop if/unless expression that can be replace with a guard clause.
      #
      # @example
      #
      #   # bad
      #   def test
      #     if something
      #       work
      #       work
      #       work
      #     end
      #   end
      #
      #   # good
      #   def test
      #     return unless something
      #     work
      #     work
      #     work
      #   end
      #
      # It should be extended to handle methods whose body is if/else
      # or a case expression with a default branch.
      class GuardClause < Cop
        include CheckMethods
        include IfNode

        MSG = 'Use a guard clause instead of wrapping ' \
              'the code inside a conditional expression.'

        private

        def check(_node, _method_name, _args, body)
          return unless body

          if body.type == :if
            check_if_node(body)
          elsif body.type == :begin
            expressions = *body
            last_expr = expressions.last

            check_if_node(last_expr) if last_expr && last_expr.type == :if
          end
        end

        def check_if_node(node)
          _cond, _body, else_body = *node

          return if else_body
          # discard modifier ifs and ternary_ops
          return if modifier_if?(node) || ternary_op?(node)
          # discard short ifs
          return unless if_length(node) > 3

          add_offense(node, :keyword)
        end

        def if_length(node)
          node.loc.end.line - node.loc.keyword.line + 1
        end
      end
    end
  end
end
