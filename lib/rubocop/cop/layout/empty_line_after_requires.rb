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
      # @example EnforcedStyle: beginning_of_file_only (default)
      #   # good
      #   foo
      #
      #   require 'a'
      #   bar
      #
      # @example EnforcedStyle: all
      #   # bad
      #   foo
      #
      #   require 'a'
      #   bar
      #
      #   # good
      #   foo
      #
      #   require 'a'
      #
      #   bar
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
          return if ignorable_beginning_of_file_requires?(node)
          return if continuous_require?(node)
          return if empty_line_after?(node)

          add_offense(node) do |corrector|
            corrector.insert_after(node, "\n")
          end
        end

        private

        def require_method_name?(method_name)
          cop_config.fetch('RequireMethodNames').include?(method_name.to_s)
        end

        def ignorable_beginning_of_file_requires?(node)
          style == :beginning_of_file_only && !beginning_of_file_requires?(node)
        end

        def beginning_of_file_requires?(node)
          top_level_scope?(node) && beginning_lines_in_scope?(node)
        end

        def top_level_scope?(node)
          node.parent == processed_source.ast
        end

        def beginning_lines_in_scope?(node)
          node.left_siblings.none? do |sibling|
            any_empty_line_between?(sibling, node)
          end
        end

        def any_empty_line_between?(node1, node2)
          processed_source[node1.loc.line...node2.loc.line - 1].any? do |line|
            line.strip.empty?
          end
        end

        def continuous_require?(node)
          require?(node.right_sibling)
        end

        def empty_line_after?(node)
          next_line = processed_source[node.loc.line]
          next_line.nil? || next_line.strip.empty?
        end
      end
    end
  end
end
