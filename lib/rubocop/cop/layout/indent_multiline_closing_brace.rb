# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for indentation of the closing brace in a
      # multi-line expression.
      #
      # Right brace in multi-line expression must align with the
      # beginning of the first line containing the expression.
      #
      # @example
      #   # bad
      #   foo(
      #     a,
      #     b
      #         )
      #
      #   # good
      #   foo(
      #     a,
      #     b
      #   )
      class IndentMultilineClosingBrace < Cop
        MSG = 'Right brace in multi-line expression must align with the ' \
              'beginning of the first line containing the expression.'.freeze

        def on_send(node)
          return if node.arguments.empty?

          check(node, node.arguments)
        end

        def on_array(node)
          check(node, node.children)
        end

        def on_hash(node)
          check(node, node.children)
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, @column_delta)
        end

        private

        def check(node, elements)
          return unless expression_uses_braces?(node)
          return if right_brace_on_same_line_as_last_element?(node, elements)
          return if node.loc.begin.first_line == node.loc.end.last_line

          @column_delta = column_delta(node)

          return if @column_delta.zero?

          add_offense(node.loc.end, location: node.loc.end)
        end

        def column_delta(node)
          first_line_index = node.loc.begin.line - 1
          first_line = processed_source.lines[first_line_index]

          first_line_indent = first_line[/\A */].size
          closing_brace_indent = node.loc.end.column

          first_line_indent - closing_brace_indent
        end

        def expression_uses_braces?(node)
          node.loc.begin
        end

        def right_brace_on_same_line_as_last_element?(node, elements)
          elements.last && node.last_line == elements.last.last_line
        end
      end
    end
  end
end
