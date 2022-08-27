# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a line break before the first element in a
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
      class FirstArrayElementLineBreak < Base
        include FirstElementLineBreak
        extend AutoCorrector

        MSG = 'Add a line break before the first element of a multi-line array.'

        def on_array(node)
          return if !node.loc.begin && !assignment_on_same_line?(node)

          check_children_line_break(node, node.children)
        end

        private

        def assignment_on_same_line?(node)
          source = node.source_range.source_line[0...node.loc.column]
          /\s*=\s*$/.match?(source)
        end
      end
    end
  end
end
