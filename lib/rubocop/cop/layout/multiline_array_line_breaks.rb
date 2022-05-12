# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Ensures that each item in a multi-line array
      # starts on a separate line.
      #
      # @example
      #
      #   # bad
      #   [
      #     a, b,
      #     c
      #   ]
      #
      #   # good
      #   [
      #     a,
      #     b,
      #     c
      #   ]
      class MultilineArrayLineBreaks < Base
        include MultilineElementLineBreaks
        extend AutoCorrector

        MSG = 'Each item in a multi-line array must start on a separate line.'

        def on_array(node)
          check_line_breaks(node, node.children)
        end
      end
    end
  end
end
