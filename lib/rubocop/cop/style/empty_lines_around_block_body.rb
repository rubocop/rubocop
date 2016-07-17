# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks if empty lines around the bodies of blocks match
      # the configuration.
      #
      # @example
      #
      #   # EnforcedStyle: empty_lines
      #
      #   # good
      #
      #   foo do |bar|
      #
      #     ...
      #
      #   end
      #
      #   # EnforcedStyle: no_empty_lines
      #
      #   # good
      #
      #   foo do |bar|
      #     ...
      #   end
      class EmptyLinesAroundBlockBody < Cop
        include EmptyLinesAroundBody

        KIND = 'block'.freeze

        def on_block(node)
          _send, _args, body = *node

          check(node, body)
        end
      end
    end
  end
end
