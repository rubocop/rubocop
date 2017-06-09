# frozen_string_literal: true

module RuboCop
  module Cop
    # Classes that include this module just implement functions to determine
    # what is an offense and how to do auto-correction. They get help with
    # adding offenses for the faulty string nodes, and with filtering out
    # nodes.
    module StringHelp
      def on_str(node)
        # Constants like __FILE__ are handled as strings,
        # but don't respond to begin.
        return unless node.loc.respond_to?(:begin) && node.loc.begin
        return if part_of_ignored_node?(node)

        if offense?(node)
          add_offense(node) { opposite_style_detected }
        else
          correct_style_detected
        end
      end

      def on_regexp(node)
        ignore_node(node)
      end

      def inside_interpolation?(node)
        # A :begin node inside a :dstr node is an interpolation.
        node.ancestors.drop_while { |a| !a.begin_type? }.any?(&:dstr_type?)
      end
    end
  end
end
