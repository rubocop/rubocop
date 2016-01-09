# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for multiple expressions placed on the same line.
      # It also checks for lines terminated with a semicolon.
      class Semicolon < Cop
        MSG = 'Do not use semicolons to terminate expressions.'.freeze

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source

          check_for_line_terminator
        end

        def on_begin(node)
          return if cop_config['AllowAsExpressionSeparator']
          exprs = node.children

          return if exprs.size < 2

          # create a map matching lines to the number of expressions on them
          exprs_lines = exprs.map { |e| e.source_range.line }
          lines = exprs_lines.group_by { |i| i }

          # every line with more than 1 expression on it is an offense
          lines.each do |line, expr_on_line|
            next unless expr_on_line.size > 1
            # TODO: Find the correct position of the semicolon. We don't know
            # if the first semicolon on the line is a separator of
            # expressions. It's just a guess.
            column = @processed_source[line - 1].index(';')
            convention_on(line, column, !:last_on_line)
          end
        end

        private

        def check_for_line_terminator
          tokens_for_lines = @processed_source.tokens.group_by do |token|
            token.pos.line
          end

          tokens_for_lines.each do |line, tokens|
            next unless tokens.last.type == :tSEMI
            convention_on(line, tokens.last.pos.column, :last_on_line)
          end
        end

        def convention_on(line, column, last_on_line)
          range = source_range(@processed_source.buffer, line, column)
          add_offense(last_on_line ? range : nil, range)
        end

        def autocorrect(range)
          return unless range
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
