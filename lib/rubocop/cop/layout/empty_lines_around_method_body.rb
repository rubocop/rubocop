# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if empty lines exist around the bodies of methods.
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     # ...
      #   end
      #
      #   # bad
      #
      #   def bar
      #
      #     # ...
      #
      #   end
      class EmptyLinesAroundMethodBody < Base
        include EmptyLinesAroundBody
        extend AutoCorrector

        KIND = 'method'

        def on_def(node)
          first_line = node.arguments.source_range&.last_line

          check(node, node.body, adjusted_first_line: first_line)
        end
        alias on_defs on_def

        private

        def style
          :no_empty_lines
        end
      end
    end
  end
end
