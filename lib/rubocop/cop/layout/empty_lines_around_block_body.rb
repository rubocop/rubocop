# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if empty lines around the bodies of blocks match
      # the configuration.
      #
      # @example EnforcedStyle: no_empty_lines (default)
      #   # bad
      #   foo do |bar|
      #
      #     # ...
      #
      #   end
      #
      #   # good
      #   foo do |bar|
      #     # ...
      #   end
      #
      # @example EnforcedStyle: empty_lines
      #   # bad
      #   foo do |bar|
      #     # ...
      #   end
      #
      #   # good
      #   foo do |bar|
      #
      #     # ...
      #
      #   end
      class EmptyLinesAroundBlockBody < Base
        include EmptyLinesAroundBody
        extend AutoCorrector

        KIND = 'block'

        def on_block(node)
          check(node, node.body, adjusted_first_line: body_start_line(node))
        end

        alias on_numblock on_block
        alias on_itblock on_block

        private

        def body_start_line(node)
          return node.loc.begin.line unless node.arguments?

          [node.loc.begin.line, node.arguments.last_line].max
        end
      end
    end
  end
end
