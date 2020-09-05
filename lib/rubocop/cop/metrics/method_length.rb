# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      #
      # You can set literals you want to fold with `CountAsOne`.
      # Available are: 'array', 'hash', and 'heredoc'. Each literal
      # will be counted as one line regardless of its actual size.
      #
      # @example CountAsOne: ['array', 'heredoc']
      #
      #   def m
      #     array = [       # +1
      #       1,
      #       2
      #     ]
      #
      #     hash = {        # +3
      #       key: 'value'
      #     }
      #
      #     <<~HEREDOC      # +1
      #       Heredoc
      #       content.
      #     HEREDOC
      #   end               # 5 points
      #
      class MethodLength < Base
        include CodeLength

        LABEL = 'Method'

        def on_def(node)
          excluded_methods = cop_config['ExcludedMethods']
          return if excluded_methods.include?(String(node.method_name))

          check_code_length(node)
        end
        alias on_defs on_def

        def on_block(node)
          return unless node.send_node.method?(:define_method)

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
