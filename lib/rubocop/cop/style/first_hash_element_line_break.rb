# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
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
              'multi-line hash.'.freeze

        def on_hash(node)
          # node.loc.begin tells us whether the hash opens with a {
          # If it doesn't, Style/FirstMethodArgumentLineBreak will handle it
          check_children_line_break(node, node.children) if node.loc.begin
        end
      end
    end
  end
end
