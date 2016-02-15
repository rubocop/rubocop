# encoding: utf-8
# frozen_string_literal: true

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
      #
      #   # bad
      #   if something
      #     raise 'exception'
      #   else
      #     ok
      #   end
      #
      #   # good
      #   raise 'exception' if something
      #   ok
      class GuardClause < Cop
        include ConfigurableEnforcedStyle
        include IfNode
        include MaxLineLength
        include MinBodyLength

        MSG = 'Use a guard clause instead of wrapping the code inside a ' \
              'conditional expression.'.freeze

        def_node_matcher :single_line_control_flow_exit?, <<-PATTERN
          [{(send nil {:raise :fail} ...) return break next} single_line?]
        PATTERN

        def on_def(node)
          _, _, body = *node
          return unless body

          if if?(body)
            check_trailing_if(body)
          elsif body.begin_type?
            last_expr = body.children.last
            check_trailing_if(last_expr) if if?(last_expr)
          end
        end

        def on_if(node)
          cond, body, else_body = *node

          return unless body && else_body
          # discard modifier ifs and ternary_ops
          return if modifier_if?(node) || ternary_op?(node) || elsif?(node)

          return unless single_line_control_flow_exit?(body) ||
                        single_line_control_flow_exit?(else_body)
          return if cond.multiline?
          return if line_too_long_when_corrected?(node)

          add_offense(node, :keyword, MSG)
        end

        private

        def if?(node)
          node && node.if_type?
        end

        def elsif?(node)
          return false unless node.parent && node.parent.if_type?
          _condition, _if_branch, else_branch = *node.parent
          else_branch.equal?(node)
        end

        def check_trailing_if(node)
          cond, body, else_body = *node

          return if body && else_body
          # discard modifier ifs and ternary_ops
          return if modifier_if?(node) || ternary_op?(node)
          return if cond.multiline?
          # discard short ifs
          return unless min_body_length?(node)
          return if line_too_long_when_corrected?(node)

          add_offense(node, :keyword, MSG)
        end

        def line_too_long_when_corrected?(node)
          cond, body, else_body = *node

          if single_line_control_flow_exit?(body) || !else_body
            line_too_long?(node, body, 'if', cond)
          else
            line_too_long?(node, else_body, 'unless', cond)
          end
        end

        def line_too_long?(node, body, keyword, condition)
          return false unless max_line_length

          indent = node.loc.column
          source = body && body.source || ''
          correction = (source + keyword + condition.source)
          # 2 is for spaces on left and right of keyword
          line_length = indent + correction.length + 2
          line_length > max_line_length
        end
      end
    end
  end
end
