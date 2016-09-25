# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for a line break before the first element in a
      # multi-line array.
      #
      # @example
      #
      #     # bad
      #     [ :a,
      #       :b]
      #
      #     # good
      #     [
      #       :a,
      #       :b]
      #
      class FirstArrayElementLineBreak < Cop
        include FirstElementLineBreak

        MSG = 'Add a line break before the first element of a ' \
              'multi-line array.'.freeze

        def on_array(node)
          return if !node.loc.begin && !assignment_on_same_line?(node)

          check_children_line_break(node, node.children)
        end

        private

        def assignment_on_same_line?(node)
          source = node.source_range.source_line[0...node.loc.column]
          source =~ /\s*\=\s*$/
        end
      end
    end
  end
end
