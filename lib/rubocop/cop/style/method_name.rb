# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that all methods use the configured style,
      # snake_case or camelCase, for their names. Some special arrangements
      # have to be made for operator methods.
      class MethodName < Cop
        include ConfigurableNaming

        def on_def(node)
          check(node, name_of_instance_method(node))
        end

        def on_defs(node)
          check(node, name_of_singleton_method(node))
        end

        def name_of_instance_method(def_node)
          expr = def_node.loc.expression
          match = /^def(\s+)([\w]+[!?=]?\b)/.match(expr.source)
          return unless match
          space, method_name = match.captures
          begin_pos = expr.begin_pos + 'def'.length + space.length
          Parser::Source::Range.new(expr.source_buffer, begin_pos,
                                    begin_pos + method_name.length)
        end

        def name_of_singleton_method(defs_node)
          scope, method_name, _args, _body = *defs_node
          after_dot(defs_node, method_name.length,
                    "def\s+" + Regexp.escape(scope.loc.expression.source))
        end

        def message(style)
          format('Use %s for methods.', style)
        end
      end
    end
  end
end
