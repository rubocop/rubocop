# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if numbering match the
    # configured EnforcedStyle.
    module ConfigurableNumbering
      include ConfigurableEnforcedStyle

      SNAKE_CASE = /(?:[a-z_]|_\d+)$/
      NORMAL_CASE = /(?:_\D*|[A-Za-z]\d*)$/
      NON_INTEGER = /[A-Za-z_]$/

      def check_name(node, name, name_range)
        return if operator?(name)

        if valid_name?(node, name)
          correct_style_detected
        else
          add_offense(node, name_range, message(style))
        end
      end

      def valid_name?(node, name)
        pattern =
          case style
          when :snake_case
            SNAKE_CASE
          when :normalcase
            NORMAL_CASE
          when :non_integer
            NON_INTEGER
          end
        name.match(pattern) || class_emitter_method?(node, name)
      end

      # A class emitter method is a singleton method in a class/module, where
      # the method has the same name as a class defined in the class/module.
      def class_emitter_method?(node, name)
        return false unless node.parent && node.defs_type?
        # a class emitter method may be defined inside `def self.included`,
        # `def self.extended`, etc.
        node = node.parent while node.parent.defs_type?

        node.parent.each_child_node(:class).any? do |c|
          c.loc.name.is?(name.to_s)
        end
      end
    end
  end
end
