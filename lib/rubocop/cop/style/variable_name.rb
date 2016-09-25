# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop makes sure that all variables use the configured style,
      # snake_case or camelCase, for their names.
      class VariableName < Cop
        include ConfigurableNaming

        def on_lvasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_ivasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_cvasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_arg(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        private

        def message(style)
          format('Use %s for variable names.', style)
        end
      end
    end
  end
end
