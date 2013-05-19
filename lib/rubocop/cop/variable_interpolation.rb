# encoding: utf-8

module Rubocop
  module Cop
    class VariableInterpolation < Cop
      def inspect(file, source, tokens, ast)
        on_node(:dstr, ast) do |s|
          var_nodes(s.children).each do |v|
            var = (v.type == :nth_ref ? '$' : '') + v.to_a[0].to_s

            if s.src.expression.to_source.include?("##{var}")
              add_offence(
                :convention,
                v.src.line,
                "Replace interpolated var #{var} with expression \#{#{var}}."
             )
            end
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
