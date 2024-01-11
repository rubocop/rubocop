# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after requires.
      #
      # @example
      #   # bad
      #   require 'a'
      #   require 'b'
      #   foo
      #
      #   # good
      #   require 'a'
      #   require 'b'
      #
      #   foo
      #
      # @example EnforcedStyle: top_level (default)
      #   # good
      #   if condition
      #     require 'a'
      #     foo
      #   end
      #
      # @example EnforcedStyle: all
      #   # bad
      #   if condition
      #     require 'a'
      #     foo
      #   end
      #
      #   # good
      #   if condition
      #     require 'a'
      #
      #     foo
      #   end
      #
      # @example RequireMethodNames: ['require', 'require_relative'] (default)
      #   # good
      #   require_dependency 'a'
      #   require_dependency 'b'
      #   foo
      #
      # @example RequireMethodNames: ['require', 'require_relative', 'require_dependency']
      #   # bad
      #   require_dependency 'a'
      #   require_dependency 'b'
      #   foo
      #
      #   # good
      #   require_dependency 'a'
      #   require_dependency 'b'
      #
      #   foo
      class EmptyLineAfterRequires < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        MSG = 'Add an empty line after requires.'

        # @!method require?(node)
        def_node_matcher :require?, <<~PATTERN
          (send nil? #require_method_name? ...)
        PATTERN

        def on_send(node)
          return unless require?(node)
          return if continuous_require?(node)
          return if empty_line_after?(node)
          return if style == :top_level && !top_level?(node)

          add_offense(node) do |corrector|
            corrector.insert_after(node, "\n")
          end
        end

        private

        def require_method_name?(method_name)
          cop_config.fetch('RequireMethodNames').include?(method_name.to_s)
        end

        def continuous_require?(node)
          require?(node.right_sibling)
        end

        def empty_line_after?(node)
          next_line = processed_source[node.loc.line]
          next_line.nil? || next_line.strip.empty?
        end

        def top_level?(node)
          node.parent == processed_source.ast
        end
      end
    end
  end
end
