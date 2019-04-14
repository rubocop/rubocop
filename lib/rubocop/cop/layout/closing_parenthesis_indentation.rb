# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of hanging closing parentheses in
      # method calls, method definitions, and grouped expressions. A hanging
      # closing parenthesis means `)` preceded by a line break.
      #
      # The default style is called 'consistent'. An alternative
      # style is 'beginning_of_first_line'. The examples below illustrates
      # the expected behavior.
      #
      # Note that the behavior in `consistent` mode is dependent on the
      # indentation of the parameters in the method call. You can use other
      # cops such as `FirstParameterIndentation` to adjust that.
      #
      # @example EnforcedStyle: consistent (default)
      #
      #   # bad
      #   foo = some_method(
      #     a,
      #     b
      #     )
      #
      #   some_method(
      #     a, b
      #     )
      #
      #   foo = some_method(a, b, c
      #     )
      #
      #   some_method(a,
      #               b,
      #               c
      #     )
      #
      #   some_method(a,
      #     x: 1,
      #     y: 2
      #     )
      #
      #   # Scenario 1: When First Parameter Is On Its Own Line
      #
      #   # good: when first param is on a new line, right paren is *always*
      #   #       outdented by IndentationWidth
      #   foo = some_method(
      #     a,
      #     b
      #   )
      #
      #   # good
      #   some_method(
      #     a, b
      #   )
      #
      #   # Scenario 2: When First Parameter Is On The Same Line
      #
      #   # good: when all other params are also on the same line, outdent
      #   #       right paren by IndentationWidth
      #   some_method(a, b, c
      #              )
      #
      #   # good: when all other params are on multiple lines, but are lined
      #   #       up, align right paren with left paren
      #   some_method(a,
      #               b,
      #               c
      #              )
      #
      #   # good: when other params are not lined up on multiple lines, outdent
      #   #       right paren by IndentationWidth
      #   some_method(a,
      #     x: 1,
      #     y: 2
      #   )
      #
      # @example EnforcedStyle: beginning_of_first_line
      #
      #   # bad
      #   foo = some_method(
      #     a,
      #     b
      #     )
      #
      #   some_method(
      #     a, b
      #     )
      #
      #   some_method(a, b, c
      #     )
      #
      #   some_method(a,
      #               b,
      #               c
      #     )
      #
      #   some_method(a,
      #     x: 1,
      #     y: 2
      #     )
      #
      #   # good: closing paren aligns with the beginning of the first line
      #   #       containing the expression (even when the first
      #   #       first parameter is on the same line as the opening
      #   #       parenthesis, or when the parameters are indented
      #   #       in a non-standard way)
      #   foo = some_method(
      #     a,
      #     b
      #   )
      #
      #   some_method(
      #     a, b
      #   )
      #
      #   some_method(a, b, c
      #   )
      #
      #   some_method(a,
      #               b,
      #               c
      #   )
      #
      #   some_method(a,
      #     x: 1,
      #     y: 2
      #   )
      #
      #   some_method(a,
      #       x: 1,
      #       y: 2
      #   )
      #
      class ClosingParenthesisIndentation < Cop
        include Alignment

        MSG_INDENT = 'Indent `)` to column %<expected>d (not %<actual>d)'
                     .freeze
        MSG_BEGINNING_OF_FIRST_LINE = 'Indent `)` to align with the ' \
          'beginning of the first line containing the expression.'.freeze
        MSG_ALIGN = 'Align `)` with `(`.'.freeze

        def on_send(node)
          check(node, node.arguments)
        end
        alias on_csend on_send

        def on_begin(node)
          check(node, node.children)
        end

        def on_def(node)
          check(node.arguments, node.arguments)
        end
        alias on_defs on_def

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, @column_delta)
        end

        private

        def check(node, elements)
          if beginning_of_first_line_mode?
            check_in_beginning_of_first_line_mode(node, elements)
          else
            check_in_consistent_mode(node, elements)
          end
        end

        def check_in_consistent_mode(node, elements)
          if elements.empty?
            check_for_no_elements(node)
          else
            check_for_elements(node, elements)
          end
        end

        def check_for_elements(node, elements)
          left_paren  = node.loc.begin
          right_paren = node.loc.end

          return unless right_paren && begins_its_line?(right_paren)

          correct_column = expected_column(left_paren, elements)

          @column_delta = correct_column - right_paren.column

          return if @column_delta.zero?

          add_offense(right_paren,
                      location: right_paren,
                      message: message(correct_column,
                                       left_paren,
                                       right_paren))
        end

        def check_for_no_elements(node)
          left_paren = node.loc.begin
          right_paren = node.loc.end
          return unless right_paren && begins_its_line?(right_paren)

          candidates = correct_column_candidates(node, left_paren)

          return if candidates.include?(right_paren.column)

          # Although there are multiple choices for a correct column,
          # select the first one of candidates to determine a specification.
          correct_column = candidates.first
          @column_delta = correct_column - right_paren.column
          add_offense(right_paren,
                      location: right_paren,
                      message: message(correct_column,
                                       left_paren,
                                       right_paren))
        end

        def expected_column(left_paren, elements)
          if line_break_after_left_paren?(left_paren, elements)
            source_indent = processed_source
                            .line_indentation(first_argument_line(elements))
            new_indent    = source_indent - indentation_width

            new_indent < 0 ? 0 : new_indent
          elsif all_elements_aligned?(elements)
            left_paren.column
          else
            processed_source.line_indentation(first_argument_line(elements))
          end
        end

        def all_elements_aligned?(elements)
          elements
            .map { |e| e.loc.column }
            .uniq
            .count == 1
        end

        def first_argument_line(elements)
          elements
            .first
            .loc
            .first_line
        end

        def correct_column_candidates(node, left_paren)
          [
            processed_source.line_indentation(left_paren.line),
            left_paren.column,
            node.loc.column
          ]
        end

        def message(correct_column, left_paren, right_paren)
          if correct_column == left_paren.column
            MSG_ALIGN
          else
            format(
              MSG_INDENT,
              expected: correct_column,
              actual: right_paren.column
            )
          end
        end

        def indentation_width
          @config.for_cop('IndentationWidth')['Width'] || 2
        end

        def line_break_after_left_paren?(left_paren, elements)
          elements.first && elements.first.loc.line > left_paren.line
        end

        def beginning_of_first_line_mode?
          cop_config['EnforcedStyle'] == 'beginning_of_first_line'
        end

        def check_in_beginning_of_first_line_mode(node, elements)
          return unless expression_uses_braces?(node)
          return if right_paren_on_same_line_as_last_element?(node, elements)
          return if node.loc.begin.first_line == node.loc.end.last_line

          @column_delta = beginning_of_first_line_column_delta(node)

          return if @column_delta.zero?

          add_offense(
            node.loc.end,
            location: node.loc.end,
            message: MSG_BEGINNING_OF_FIRST_LINE
          )
        end

        def beginning_of_first_line_column_delta(node)
          first_line_index = node.loc.begin.line - 1
          first_line = processed_source.lines[first_line_index]

          first_line_indent = first_line[/\A */].size
          closing_brace_indent = node.loc.end.column

          first_line_indent - closing_brace_indent
        end

        def expression_uses_braces?(node)
          node.loc.begin
        end

        def right_paren_on_same_line_as_last_element?(node, elements)
          elements.last && node.last_line == elements.last.last_line
        end
      end
    end
  end
end
