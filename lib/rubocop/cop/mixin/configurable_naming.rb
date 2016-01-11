# encoding: utf-8
# frozen_string_literal: true

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

        if valid_name?(node, name)
          correct_style_detected
        else
          add_offense(node, name_range, message(style)) do
            opposite_style_detected
          end
        end
      end

      def valid_name?(node, name)
        pattern = (style == :snake_case ? SNAKE_CASE : CAMEL_CASE)
        name.match(pattern) || class_emitter_method?(node, name)
      end

      # A class emitter method is a singleton method in a class/module, where
      # the method has the same name as a class defined in the class/module.
      def class_emitter_method?(node, name)
        return false unless node.defs_type?
        # a class emitter method may be defined inside `def self.included`,
        # `def self.extended`, etc.
        node = node.parent while node.parent && node.parent.defs_type?
        return false unless node.parent

        node.parent.children.compact.any? do |c|
          c.class_type? && c.loc.name.is?(name.to_s)
        end
      end
    end
  end
end
