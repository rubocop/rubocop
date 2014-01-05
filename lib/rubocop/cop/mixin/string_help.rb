# encoding: utf-8

module Rubocop
  module Cop
    # Classes that include this module just implement functions to determine
    # what is an offence and how to do auto-correction. They get help with
    # adding offences for the faulty string nodes, and with filtering out
    # nodes.
    module StringHelp
      def on_str(node)
        # Constants like __FILE__ are handled as strings,
        # but don't respond to begin.
        return unless node.loc.respond_to?(:begin) && node.loc.begin
        return if part_of_ignored_node?(node)

        if offence?(node)
          add_offence(node, :expression) { opposite_style_detected }
        else
          correct_style_detected
        end
      end

      def on_dstr(node)
        ignore_node(node)
      end

      def on_regexp(node)
        ignore_node(node)
      end
    end
  end
end
