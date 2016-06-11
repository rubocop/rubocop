# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of hanging closing parentheses in
      # method calls, method definitions, and grouped expressions. A hanging
      # closing parenthesis means `)` preceded by a line break.
      #
      # @example
      #
      #   # good: when x is on its own line, indent this way
      #   func(
      #     x,
      #     y
      #   )
      #
      #   # good: when x follows opening parenthesis, align parentheses
      #   a = b * (x +
      #            y
      #           )
      #
      #   # bad
      #   def func(
      #     x,
      #     y
      #     )
      class ClosingParenthesisIndentation < Cop
        include AutocorrectAlignment
        include OnMethodDef

        MSG_INDENT =
          'Indent `)` the same as the start of the line where `(` is.'.freeze
        MSG_ALIGN = 'Align `)` with `(`.'.freeze

        def on_send(node)
          _receiver, _method_name, *args = *node
          check(node, args)
        end

        def on_begin(node)
          check(node, node.children)
        end

        private

        def on_method_def(_node, _method_name, args, _body)
          check(args, args.children)
        end

        def check(node, elements)
          right_paren = node.loc.end
          return unless right_paren
          return unless begins_its_line?(right_paren)

          left_paren = node.loc.begin

          correct_column = if node.send_type? && fixed_parameter_indentation? ||
                              line_break_after_left_paren?(left_paren, elements)
                             left_paren.source_line =~ /\S/
                           else
                             left_paren.column
                           end
          @column_delta = correct_column - right_paren.column
          return if @column_delta == 0

          msg = correct_column == left_paren.column ? MSG_ALIGN : MSG_INDENT
          add_offense(node.loc.end, node.loc.end, msg)
        end

        def fixed_parameter_indentation?
          config.for_cop('Style/AlignParameters')['EnforcedStyle'] ==
            'with_fixed_indentation'
        end

        def line_break_after_left_paren?(left_paren, elements)
          elements.first && elements.first.loc.line > left_paren.line
        end
      end
    end
  end
end
