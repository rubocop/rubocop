# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for variable interpolation (like "#@ivar").
      class VariableInterpolation < Cop
        MSG = 'Replace interpolated variable `%s` with expression `#{%s}`.'

        def on_dstr(node)
          var_nodes(node.children).each do |v|
            var = v.loc.expression.source

            add_offense(v, :expression, format(MSG, var, var))
          end
        end

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            expr = node.loc.expression
            corrector.replace(expr, "{#{expr.source}}")
          end
        end

        def var_nodes(nodes)
          nodes.select { |n| [:ivar, :cvar, :gvar, :nth_ref].include?(n.type) }
        end
      end
    end
  end
end
