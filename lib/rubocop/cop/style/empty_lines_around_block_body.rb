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
      #   something do
      #
      #     ...
      #   end
      #
      class EmptyLinesAroundBlockBody < Cop
        include EmptyLinesAroundBody

        KIND = 'block'.freeze

        def on_block(node)
          _send, _args, body = *node
          check(node, body)
        end

        private

        def check(node, body)
          return unless body || style == :no_empty_lines

          start_line = node.loc.begin.line
          end_line = node.loc.end.line

          return if start_line == end_line

          check_source(start_line, end_line)
        end
      end
    end
  end
end
