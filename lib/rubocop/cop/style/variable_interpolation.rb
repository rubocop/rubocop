# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for variable interpolation (like "#@ivar").
      class VariableInterpolation < Cop
        MSG = 'Replace interpolated var %s with expression #{%s}.'

        def on_dstr(node)
          var_nodes(node.children).each do |v|
            var = (v.type == :nth_ref ? '$' : '') + v.to_a[0].to_s

            if node.loc.expression.source.include?("##{var}")
              add_offence(v, :expression, sprintf(MSG, var, var))
            end
          end
        end

        private

        def var_nodes(nodes)
          nodes.select { |n| [:ivar, :cvar, :gvar, :nth_ref].include?(n.type) }
        end
      end
    end
  end
end
