# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the formatting of empty method definitions.
      # By default it enforces empty method definitions to go on a single
      # line (compact style), but it can be configured to enforce the `end`
      # to go on its own line (expanded style).
      #
      # Note: A method definition is not considered empty if it contains
      #       comments.
      #
      # @example EnforcedStyle: compact (default)
      #   # bad
      #   def foo(bar)
      #   end
      #
      #   def self.foo(bar)
      #   end
      #
      #   # good
      #   def foo(bar); end
      #
      #   def foo(bar)
      #     # baz
      #   end
      #
      #   def self.foo(bar); end
      #
      # @example EnforcedStyle: expanded
      #   # bad
      #   def foo(bar); end
      #
      #   def self.foo(bar); end
      #
      #   # good
      #   def foo(bar)
      #   end
      #
      #   def self.foo(bar)
      #   end
      class EmptyMethod < Cop
        include ConfigurableEnforcedStyle

        MSG_COMPACT = 'Put empty method definitions on a single line.'.freeze
        MSG_EXPANDED = 'Put the `end` of empty method definitions on the ' \
                       'next line.'.freeze

        def on_def(node)
          return if node.body || comment_lines?(node)
          return if correct_style?(node)

          add_offense(node)
        end
        alias on_defs on_def

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, corrected(node))
          end
        end

        private

        def message(_node)
          compact_style? ? MSG_COMPACT : MSG_EXPANDED
        end

        def correct_style?(node)
          compact_style? && compact?(node) ||
            expanded_style? && expanded?(node)
        end

        def corrected(node)
          arguments = node.arguments? ? node.arguments.source : ''
          scope     = node.receiver ? "#{node.receiver.source}." : ''

          signature = [scope, node.method_name, arguments].join

          ["def #{signature}", 'end'].join(joint(node))
        end

        def joint(node)
          indent = ' ' * node.loc.column

          compact_style? ? '; ' : "\n#{indent}"
        end

        def comment_lines?(node)
          processed_source[line_range(node)].any? { |line| comment_line?(line) }
        end

        def compact?(node)
          node.single_line?
        end

        def expanded?(node)
          node.multiline?
        end

        def compact_style?
          style == :compact
        end

        def expanded_style?
          style == :expanded
        end
      end
    end
  end
end
