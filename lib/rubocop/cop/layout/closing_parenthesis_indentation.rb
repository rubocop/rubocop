# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks the indentation of hanging closing parentheses in
      # method calls, method definitions, and grouped expressions. A hanging
      # closing parenthesis means `)` preceded by a line break.
      #
      # @example
      #
      #   # bad
      #   some_method(
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
      #   # Scenario 1: When First Parameter Is On Its Own Line
      #
      #   # good: when first param is on a new line, right paren is *always*
      #   #       outdented by IndentationWidth
      #   some_method(
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
      #
      class ClosingParenthesisIndentation < Cop
        include Alignment

        MSG_INDENT = 'Indent `)` to column %<expected>d (not %<actual>d)'
                     .freeze
        MSG_ALIGN = 'Align `)` with `(`.'.freeze

        def on_send(node)
          check(node, node.arguments)
        end

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
          left_paren  = node.loc.begin
          right_paren = node.loc.end

          return unless right_paren && begins_its_line?(right_paren)

          correct_column = expected_column(left_paren, elements)

          @column_delta = correct_column - right_paren.column

          return if @column_delta.zero?

          add_offense(right_paren,
                      location: right_paren,
                      message:  message(correct_column,
                                        left_paren,
                                        right_paren))
        end

        def expected_column(left_paren, elements)
          if !line_break_after_left_paren?(left_paren, elements) &&
             all_elements_aligned?(elements)
            left_paren.column
          else
            source_indent = processed_source
                            .line_indentation(last_argument_line(elements))
            new_indent    = source_indent - indentation_width

            new_indent < 0 ? 0 : new_indent
          end
        end

        def all_elements_aligned?(elements)
          elements
            .map { |e| e.loc.column }
            .uniq
            .count == 1
        end

        def last_argument_line(elements)
          elements
            .last
            .loc
            .first_line
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
      end
    end
  end
end
