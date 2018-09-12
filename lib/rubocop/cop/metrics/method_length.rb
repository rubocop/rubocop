# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include TooManyLines

        LABEL = 'Method'.freeze

        def on_def(node)
          return if excluded_method?(node)
          
          check_code_length(node)
        end
        alias on_defs on_def

        def on_block(node)
          return unless node.send_node.method_name == :define_method
          
          check_code_length(node)
        end

        private

        def excluded_method?(node)
          node_method = String(node.method_name)

          excluded_methods.any? do |method|
            method == node_method
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
