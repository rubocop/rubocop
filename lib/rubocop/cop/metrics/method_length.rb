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
      # NOTE: The `ExcludedMethods` configuration is deprecated and only kept
      # for backwards compatibility. Please use `IgnoredMethods` instead.
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
        include IgnoredMethods

        ignored_methods deprecated_key: 'ExcludedMethods'

        LABEL = 'Method'

        def on_def(node)
          return if ignored_method?(node.method_name)

          check_code_length(node)
        end
        alias on_defs on_def

        def on_block(node)
          return unless node.send_node.method?(:define_method)

          check_code_length(node)
        end
        alias on_numblock on_block

        private

        def cop_label
          LABEL
        end
      end
    end
  end
end
