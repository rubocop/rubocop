# encoding: utf-8

module RuboCop
  module Cop
    # This module provides functionality for checking if names match the
    # configured EnforcedStyle.
    module ConfigurableNaming
      include ConfigurableEnforcedStyle

      SNAKE_CASE = /^@{0,2}[\da-z_]+[!?=]?$/
      CAMEL_CASE = /^@{0,2}[a-z][\da-zA-Z]+[!?=]?$/

      def check_name(node, name, name_range)
        return if operator?(name)

        if valid_name?(name)
          correct_style_detected
        else
          add_offense(node, name_range, message(style)) do
            opposite_style_detected
          end
        end
      end

      def valid_name?(name)
        pattern = (style == :snake_case ? SNAKE_CASE : CAMEL_CASE)
        name.match(pattern)
      end
    end
  end
end
