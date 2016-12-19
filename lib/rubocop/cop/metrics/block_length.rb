# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a block exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      # The cop can be configured to ignore blocks passed to certain methods.
      class BlockLength < Cop
        include TooManyLines

        LABEL = 'Block'.freeze

        def on_block(node)
          return if excluded_methods.include?(node.method_name.to_s)
          check_code_length(node)
        end

        private

        def excluded_methods
          cop_config['ExcludedMethods'] || []
        end

        def cop_label
          LABEL
        end
      end
    end
  end
end
