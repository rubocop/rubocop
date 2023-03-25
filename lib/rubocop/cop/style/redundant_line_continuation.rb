# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Check for redundant line continuation.
      #
      # This cop marks a line continuation as redundant if removing the backslash
      # does not result in a syntax error.
      # However, a backslash at the end of a comment or
      # for string concatenation is not redundant and is not considered an offense.
      #
      # @example
      #   # bad
      #   foo. \
      #     bar
      #   foo \
      #     &.bar \
      #       .baz
      #
      #   # good
      #   foo.
      #     bar
      #   foo
      #     &.bar
      #       .baz
      #
      #   # bad
      #   [foo, \
      #     bar]
      #   {foo: \
      #     bar}
      #
      #   # good
      #   [foo,
      #     bar]
      #   {foo:
      #     bar}
      #
      #   # bad
      #   foo(bar, \
      #     baz)
      #
      #   # good
      #   foo(bar,
      #     baz)
      #
      #   # also good - backslash in string concatenation is not redundant
      #   foo('bar' \
      #     'baz')
      #
      #   # also good - backslash at the end of a comment is not redundant
      #   foo(bar, # \
      #     baz)
      #
      #   # also good - backslash at the line following the newline begins with a + or -,
      #   # it is not redundant
      #   1 \
      #     + 2 \
      #       - 3
      #
      #   # also good - backslash with newline between the method name and its arguments,
      #   # it is not redundant.
      #   some_method \
      #     (argument)
      #
      class RedundantLineContinuation < Base
        include MatchRange
        extend AutoCorrector

        MSG = 'Redundant line continuation.'

        def on_new_investigation
          return unless processed_source.ast

          each_match_range(processed_source.ast.source_range, /(\\\n)/) do |range|
            next if require_line_continuation?(range)
            next unless redundant_line_continuation?(range)

            add_offense(range) do |corrector|
              corrector.remove_leading(range, 1)
            end
          end
        end

        private

        def require_line_continuation?(range)
          !ends_with_backslash_without_comment?(range.source_line) ||
            string_concatenation?(range.source_line) ||
            starts_with_plus_or_minus?(processed_source[range.line])
        end

        def ends_with_backslash_without_comment?(source_line)
          source_line.gsub(/#.+/, '').end_with?('\\')
        end

        def string_concatenation?(source_line)
          /["']\s*\\\z/.match?(source_line)
        end

        def redundant_line_continuation?(range)
          return true unless (node = find_node_for_line(range.line))
          return false if argument_newline?(node)

          parse(node.source.gsub(/\\\n/, "\n")).valid_syntax?
        end

        def argument_newline?(node)
          node = node.children.first if node.root? && node.begin_type?
          return if !node.send_type? || node.arguments.empty?

          node.loc.selector.line != node.first_argument.loc.line
        end

        def find_node_for_line(line)
          processed_source.ast.each_node do |node|
            return node if same_line?(node, line)
          end
        end

        def same_line?(node, line)
          return unless (source_range = node.source_range)

          if node.is_a?(AST::StrNode)
            if node.heredoc?
              (node.loc.heredoc_body.line..node.loc.heredoc_body.last_line).cover?(line)
            else
              (source_range.line..source_range.last_line).cover?(line)
            end
          else
            source_range.line == line
          end
        end

        def starts_with_plus_or_minus?(source_line)
          %r{\A\s*[+\-*/%]}.match?(source_line)
        end
      end
    end
  end
end
