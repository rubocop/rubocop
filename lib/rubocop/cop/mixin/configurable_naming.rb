# encoding: utf-8

module Rubocop
  module Cop
    # This module provides functionality for checking if names match the
    # configured EnforcedStyle.
    module ConfigurableNaming
      include ConfigurableEnforcedStyle

      SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/
      CAMEL_CASE = /^@?[a-z][\da-zA-Z]+[!?=]?$/
      WHITE_SPACE = /^@?[\da-z[:space:]]+[!?=]?$/

      def check(node, range)
        return unless range

        name = range.source.to_sym
        return if operator?(name)

        if matches_config?(name)
          correct_style_detected
        elsif (different_style = matches_any_config?(name))
          add_offense(node, range, message(style)) do
            different_style_detected(different_style)
          end
        else
          add_offense(node, range, message(style)) do
            unrecognized_style_detected
          end
        end
      end

      def matches_any_config?(name)
        case name
        when SNAKE_CASE then :snake_case
        when CAMEL_CASE then :camelCase
        when WHITE_SPACE then :"white space"
        else nil
        end
      end

      def matches_config?(name)
        name =~ case style
                when :snake_case then SNAKE_CASE
                when :camelCase then CAMEL_CASE
                when :"white space" then WHITE_SPACE
                end
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
