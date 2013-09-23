# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that all variables use the configured style,
      # snake_case or camelCase, for their names.
      class VariableName < Cop
        include ConfigurableNaming

        def on_lvasgn(node)
          check(node, name_of_variable(node))
        end

        def on_ivasgn(node)
          check(node, name_of_variable(node))
        end

        def on_send(node)
          check(node, name_of_setter(node))
        end

        def name_of_variable(vasgn_node)
          expr = vasgn_node.loc.expression
          name = vasgn_node.children.first
          Parser::Source::Range.new(expr.source_buffer, expr.begin_pos,
                                    expr.begin_pos + name.length)
        end

        def name_of_setter(send_node)
          receiver, method_name = *send_node
          return unless receiver && receiver.type == :self
          return unless method_name.to_s.end_with?('=')
          after_dot(send_node, method_name.length - '='.length,
                    Regexp.escape(receiver.loc.expression.source))
        end

        def message(style)
          format('Use %s for variables.', style)
        end
      end
    end
  end
end
