# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that all methods use the configured style,
      # snake_case or camelCase, for their names.
      #
      # This cop has `IgnoredPatterns` configuration option.
      #
      #   Naming/MethodName:
      #     IgnoredPatterns:
      #       - '\A\s*onSelectionBulkChange\s*'
      #       - '\A\s*onSelectionCleared\s*'
      #
      # Method names matching patterns are always allowed.
      #
      # @example EnforcedStyle: snake_case (default)
      #   # bad
      #   def fooBar; end
      #
      #   # good
      #   def foo_bar; end
      #
      # @example EnforcedStyle: camelCase
      #   # bad
      #   def foo_bar; end
      #
      #   # good
      #   def fooBar; end
      class MethodName < Cop
        include ConfigurableNaming
        include IgnoredPattern

        MSG = 'Use %<style>s for method names.'

        def on_def(node)
          return if node.operator_method? ||
                    matches_ignored_pattern?(node.method_name)

          check_name(node, node.method_name, node.loc.name)
        end
        alias on_defs on_def

        private

        def message(style)
          format(MSG, style: style)
        end
      end
    end
  end
end
