# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for multiple expressions placed on the same line.
      # It also checks for lines terminated with a semicolon.
      class Semicolon < Cop
        MSG = 'Do not use semicolons to terminate expressions.'

        def investigate(processed_source)
          return unless processed_source.ast

          unless cop_config['AllowAsExpressionSeparator']
            check_for_expr_separator(processed_source)
          end
          check_for_line_terminator(processed_source)
        end

        private

        def check_for_expr_separator(processed_source)
          on_node(:begin, processed_source.ast) do |node|
            exprs = node.children

            next if exprs.size < 2

            # create a map matching lines to the number of expressions on them
            exprs_lines = exprs.map { |e| e.loc.expression.line }
            lines = exprs_lines.group_by { |i| i }

            # every line with more than 1 expression on it is an offence
            lines.each do |line, expr_on_line|
              if expr_on_line.size > 1
                # TODO: Find the correct position of the semicolon. We don't
                # know if the first semicolon on the line is a separator of
                # expressions. It's just a guess.
                column = processed_source[line - 1].index(';')
                convention(nil,
                           source_range(processed_source.buffer,
                                        processed_source[0...(line - 1)],
                                        column, 1))
              end
            end
          end
        end

        def check_for_line_terminator(processed_source)
          tokens_for_lines = processed_source.tokens.group_by do |token|
            token.pos.line
          end

          tokens_for_lines.each do |line, tokens|
            if tokens.last.type == :tSEMI # rubocop:disable SymbolName
              column = tokens.last.pos.column
              convention(nil,
                         source_range(processed_source.buffer,
                                      processed_source[0...(line - 1)],
                                      column, 1))
            end
          end
        end
      end
    end
  end
end
