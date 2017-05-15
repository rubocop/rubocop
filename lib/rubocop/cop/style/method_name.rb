# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop makes sure that all methods use the configured style,
      # snake_case or camelCase, for their names. Some special arrangements
      # have to be made for operator methods.
      class MethodName < Cop
        include ConfigurableNaming

        def on_def(node)
          name, = *node
          check_name(node, sanitize_name(name), node.loc.name)
        end

        def on_defs(node)
          _object, name, = *node
          check_name(node, sanitize_name(name), node.loc.name)
        end

        private

        def message(style)
          format('Use %s for method names.', style)
        end

        def sanitize_name(name)
          name.to_s.delete('@').to_sym
        end
      end
    end
  end
end
