# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks if empty lines around the bodies of blocks match
      # the configuration.
      #
      # @example EnforcedStyle: empty_lines
      #   # good
      #
      #   foo do |bar|
      #
      #     # ...
      #
      #   end
      #
      # @example EnforcedStyle: no_empty_lines (default)
      #   # good
      #
      #   foo do |bar|
      #     # ...
      #   end
      class EmptyLinesAroundBlockBody < Base
        include EmptyLinesAroundBody
        extend AutoCorrector

        KIND = 'block'

        def on_block(node)
          first_line = node.send_node.last_line

          check(node, node.body, adjusted_first_line: first_line)
        end
      end
    end
  end
end
