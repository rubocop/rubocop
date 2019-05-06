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

        LABEL = 'Block'

        def on_block(node)
          return if excluded_method?(node)
          return if node.class_constructor?

          check_code_length(node)
        end

        private

        def excluded_method?(node)
          node_receiver = node.receiver&.source&.gsub(/\s+/, '')
          node_method = String(node.method_name)

          excluded_methods.any? do |config|
            receiver, method = config.split('.')

            unless method
              method = receiver
              receiver = node_receiver
            end

            method == node_method && receiver == node_receiver
          end
        end

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
