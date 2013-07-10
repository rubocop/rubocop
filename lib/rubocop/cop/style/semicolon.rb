# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for multiple expressions placed on the same line.
      # It also checks for lines terminated with a semicolon.
      class Semicolon < Cop
        MSG = 'Do not use semicolons to terminate expressions.'

        def source_callback(source_buffer, source, tokens, ast, comments)
          return unless ast

          on_node(:begin, ast) do |node|
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
                column = source[line - 1].index(';')
                add_offence(:convention,
                            source_range(source_buffer, source[0...(line - 1)],
                                         column, 1),
                            MSG)
              end
            end
          end

          tokens.group_by { |t| t.pos.line }.each do |line, line_tokens|
            if line_tokens.last.type == :tSEMI # rubocop:disable SymbolName
              column = line_tokens.last.pos.column
              add_offence(:convention,
                          source_range(source_buffer, source[0...(line - 1)],
                                       column, 1),
                          MSG)
            end
          end
        end
      end
    end
  end
end
