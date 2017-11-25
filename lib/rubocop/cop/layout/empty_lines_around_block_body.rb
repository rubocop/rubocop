# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines around the bodies of blocks match
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
      class EmptyLinesAroundBlockBody < Cop
        include EmptyLinesAroundBody

        KIND = 'block'.freeze

        def on_block(node)
          check(node, node.body)
        end
      end
    end
  end
end
