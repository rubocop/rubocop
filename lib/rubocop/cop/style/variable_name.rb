# encoding: utf-8

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

        # TODO: Why is this checking invocations of setter rather than
        #   definitions? Also, this is not variable.
        def on_send(node)
          return unless setter_call_on_self?(node)
          _receiver, method_name, = *node
          attribute_name = method_name.to_s.sub(/=$/, '').to_sym
          check_name(node, attribute_name, node.loc.selector)
        end

        private

        def message(style)
          format('Use %s for variables.', style)
        end

        def setter_call_on_self?(send_node)
          receiver, method_name, = *send_node
          return false unless receiver && receiver.type == :self
          method_name.to_s.end_with?('=')
        end
      end
    end
  end
end
