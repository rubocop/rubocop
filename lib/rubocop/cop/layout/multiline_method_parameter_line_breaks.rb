# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Ensures that each parameter in a multi-line method definition
      # starts on a separate line.
      #
      # NOTE: This cop does not move the first argument, if you want that to
      # be on a separate line, see `Layout/FirstMethodParameterLineBreak`.
      #
      # @example
      #
      #   # bad
      #   def foo(a, b,
      #     c
      #   )
      #   end
      #
      #   # good
      #   def foo(
      #     a,
      #     b,
      #     c
      #   )
      #   end
      #
      #   # good
      #   def foo(a, b, c)
      #   end
      class MultilineMethodParameterLineBreaks < Base
        include MultilineElementLineBreaks
        extend AutoCorrector

        MSG = 'Each parameter in a multi-line method definition must start on a separate line.'

        def on_def(node)
          return if node.arguments.empty?

          check_line_breaks(node, node.arguments)
        end
      end
    end
  end
end
