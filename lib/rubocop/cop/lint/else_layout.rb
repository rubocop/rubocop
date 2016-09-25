# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for odd else block layout - like
      # having an expression on the same line as the else keyword,
      # which is usually a mistake.
      #
      # @example
      #
      #   if something
      #     ...
      #   else do_this
      #     do_that
      #   end
      class ElseLayout < Cop
        include IfNode

        def on_if(node)
          return if ternary?(node)
          # ignore modifier ops & elsif nodes
          return unless node.loc.end

          check(node)
        end

        private

        def check(node)
          return unless node
          return check_else(node) if else?(node)

          check_if(node) if if?(node)
        end

        def check_else(node)
          _cond, _if_branch, else_branch = *node
          return unless else_branch && else_branch.begin_type?

          first_else_expr = else_branch.children.first
          return unless first_else_expr.source_range.line == node.loc.else.line

          add_offense(first_else_expr, :expression, message)
        end

        def check_if(node)
          _cond, _if_branch, else_branch = *node
          check(else_branch)
        end

        def if?(node)
          node.loc.respond_to?(:keyword) &&
            %w(if elsif).include?(node.loc.keyword.source)
        end

        def else?(node)
          node.loc.respond_to?(:else) && node.loc.else &&
            node.loc.else.is?('else')
        end

        def message
          'Odd `else` layout detected. Did you mean to use `elsif`?'
        end
      end
    end
  end
end
