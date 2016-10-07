# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a block exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class BlockLength < Cop
        include CodeLength

        def on_block(node)
          check_code_length(node)
        end

        private

        def message(length, max_length)
          format('Block has too many lines. [%d/%d]', length, max_length)
        end

        def code_length(node)
          lines = node.source.lines.to_a[1..-2] || []

          lines.count { |line| !irrelevant_line(line) }
        end
      end
    end
  end
end
