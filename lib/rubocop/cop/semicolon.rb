# encoding: utf-8

module Rubocop
  module Cop
    class Semicolon < Cop
      ERROR_MESSAGE = 'Do not use semicolons to terminate expressions.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:begin, sexp) do |s|
          exprs = s.children

          next if exprs.size < 2

          # create a map matching lines to the number of expressions on them
          exprs_lines = exprs.map { |e| e.src.expression.line }
          lines = exprs_lines.group_by { |i| i }

          # every line with more than 1 expression on it is an offence
          lines.each do |line, expr_on_line|
            if expr_on_line.size > 1
              add_offence(:convention, line, ERROR_MESSAGE)
            end
          end
        end

        # not pretty reliable, but the best we can do for now
        source.each_with_index do |line, index|
          add_offence(:convention, index, ERROR_MESSAGE) if line =~ /;\s*\z/
        end
      end
    end
  end
end
