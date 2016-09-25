# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for variable interpolation (like "#@ivar").
      class VariableInterpolation < Cop
        MSG = 'Replace interpolated variable `%s` ' \
              'with expression `#{%s}`.'.freeze

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
            var = v.source
            add_offense(v, :expression, format(MSG, var, var))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, "{#{node.source}}")
          end
        end

        def var_nodes(nodes)
          nodes.select { |n| n.variable? || n.reference? }
        end
      end
    end
  end
end
