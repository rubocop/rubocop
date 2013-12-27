# encoding: utf-8

module Rubocop
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
        def on_if(node)
          # ignore ternary ops
          return if node.loc.respond_to?(:question)
          # ignore modifier ops & elsif nodes
          return unless node.loc.end

          check(node)
        end

        private

        def check(node)
          return unless node

          if node.loc.respond_to?(:else) &&
             node.loc.else &&
             node.loc.else.is?('else')
            _cond, _if_branch, else_branch = *node

            return unless else_branch && else_branch.type == :begin

            first_else_expr = else_branch.children.first

            if first_else_expr.loc.expression.line == node.loc.else.line
              add_offence(first_else_expr, :expression, message)
            end
          elsif node.loc.respond_to?(:keyword) &&
                %w(if elsif).include?(node.loc.keyword.source)
            _cond, _if_branch, else_branch = *node
            check(else_branch)
          end
        end

        def message
          'Odd else layout detected. Perhaps you meant to use elsif instead?'
        end
      end
    end
  end
end
