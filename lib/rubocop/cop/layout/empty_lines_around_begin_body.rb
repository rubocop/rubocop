
# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines exist around the bodies of begin-end
      # blocks.
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     # ...
      #   end
      #
      #   # bad
      #
      #   begin
      #
      #     # ...
      #
      #   end
      class EmptyLinesAroundBeginBody < Cop
        include EmptyLinesAroundBody

        KIND = '`begin`'.freeze

        def on_kwbegin(node)
          check(node, nil)
        end

        private

        def style
          :no_empty_lines
        end
      end
    end
  end
end
