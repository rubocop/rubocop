# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Use a guard clause instead of wrapping the code inside a conditional
      # expression
      #
      # @example
      #   # bad
      #   def test
      #     if something
      #       work
      #     end
      #   end
      #
      #   # good
      #   def test
      #     return unless something
      #     work
      #   end
      #
      #   # also good
      #   def test
      #     work if something
      #   end
      class GuardClause < Cop
        include ConfigurableEnforcedStyle
        include IfNode
        include MinBodyLength

        MSG = 'Use a guard clause instead of wrapping the code inside a ' \
              'conditional expression.'

        def on_def(node)
          _, _, body = *node
          return unless body

          if if?(body)
            check_if_node(body)
          elsif body.type == :begin
            expressions = *body
            last_expr = expressions.last

            check_if_node(last_expr) if if?(last_expr)
          end
        end

        private

        def if?(body)
          body && body.type == :if
        end

        def check_if_node(node)
          _cond, body, else_body = *node

          return if body && else_body
          # discard modifier ifs and ternary_ops
          return if modifier_if?(node) || ternary_op?(node)
          # discard short ifs
          return unless min_body_length?(node)

          add_offense(node, :keyword, MSG)
        end
      end
    end
  end
end
