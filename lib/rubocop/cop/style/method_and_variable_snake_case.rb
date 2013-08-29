# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that all methods and variables use
      # snake_case for their names. Some special arrangements have to be
      # made for operator methods.
      class MethodAndVariableSnakeCase < Cop
        MSG = 'Use snake_case for methods and variables.'
        SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/

        def investigate(processed_source)
          ast = processed_source.ast
          return unless ast
          on_node([:def, :defs, :lvasgn, :ivasgn, :send], ast) do |n|
            range = case n.type
                    when :def             then name_of_instance_method(n)
                    when :defs            then name_of_singleton_method(n)
                    when :lvasgn, :ivasgn then name_of_variable(n)
                    when :send            then name_of_setter(n)
                    end

            next unless range
            name = range.source.to_sym
            next if name =~ SNAKE_CASE || OPERATOR_METHODS.include?(name)

            convention(n, range, MSG)
          end
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

        # Returns a range containing the method name after the given regexp and
        # a dot.
        def after_dot(node, method_name_length, regexp)
          expr = node.loc.expression
          match = /\A#{regexp}\s*\.\s*/.match(expr.source)
          return unless match
          offset = match[0].length
          begin_pos = expr.begin_pos + offset
          Parser::Source::Range.new(expr.source_buffer, begin_pos,
                                    begin_pos + method_name_length)
        end
      end
    end
  end
end
