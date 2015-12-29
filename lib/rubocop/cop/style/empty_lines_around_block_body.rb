# encoding: utf-8

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

        KIND = 'block'

        def on_block(node)
          check(node)
        end

        private

        def check(node)
          start_line = node.loc.begin.line
          end_line = node.loc.end.line

          return if start_line == end_line

          check_source(node, start_line, end_line)
        end
      end
    end
  end
end
