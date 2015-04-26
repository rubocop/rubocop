# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for variable interpolation (like "#@ivar").
      class VariableInterpolation < Cop
        MSG = 'Replace interpolated variable `%s` with expression `#{%s}`.'

        def on_dstr(node)
          check_for_interpolation(node)
        end

        def on_regexp(node)
          check_for_interpolation(node)
        end

        def on_xstr(node)
          check_for_interpolation(node)
        end

        private

        def check_for_interpolation(node)
          var_nodes(node.children).each do |v|
            var = v.loc.expression.source

            add_offense(v, :expression, format(MSG, var, var))
          end
        end

        def autocorrect(node)
          expr = node.loc.expression
          ->(corrector) { corrector.replace(expr, "{#{expr.source}}") }
        end

        def var_nodes(nodes)
          nodes.select { |n| [:ivar, :cvar, :gvar, :nth_ref].include?(n.type) }
        end
      end
    end
  end
end
