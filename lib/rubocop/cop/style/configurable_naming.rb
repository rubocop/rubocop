# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This module provides functionality for checking if names match the
      # configured EnforcedStyle.
      module ConfigurableNaming
        include ConfigurableEnforcedStyle

        SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/
        CAMEL_CASE = /^@?[a-z][\da-zA-Z]+[!?=]?$/

        def check(node, range)
          return unless range

          name = range.source.to_sym
          unless matches_config?(name) || Cop::OPERATOR_METHODS.include?(name)
            add_offence(node, range, message(style))
          end
        end

        def matches_config?(name)
          name =~ (style == :snake_case ? SNAKE_CASE : CAMEL_CASE)
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
