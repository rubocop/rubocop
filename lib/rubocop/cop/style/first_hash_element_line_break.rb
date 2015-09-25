# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for a line break before the first element in a
      # multi-line hash.
      #
      # @example
      #
      #     # bad
      #     { a: 1,
      #       b: 2}
      #
      #     # good
      #     {
      #       a: 1,
      #       b: 2 }
      class FirstHashElementLineBreak < Cop
        include FirstElementLineBreak

        MSG = 'Add a line break before the first element of a ' \
              'multi-line hash.'

        def on_hash(node)
          if node.loc.begin
            check_children_line_break(node, node.children)
          elsif method_uses_parens?(node.parent, node)
            check_children_line_break(node, node.children, node.parent)
          end
        end
      end
    end
  end
end
