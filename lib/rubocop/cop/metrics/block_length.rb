# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a block exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class BlockLength < Cop
        include TooManyLines

        LABEL = 'Block'.freeze

        def on_block(node)
          check_code_length(node)
        end

        private

        def cop_label
          LABEL
        end
      end
    end
  end
end
