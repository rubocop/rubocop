# encoding: utf-8

module Rubocop
  module Cop
    class Semicolon < Cop
      MSG = 'Do not use semicolons to terminate expressions.'

      def inspect(file, source, tokens, ast)
        on_node(:begin, ast) do |node|
          exprs = node.children

          next if exprs.size < 2

          # create a map matching lines to the number of expressions on them
          exprs_lines = exprs.map { |e| e.src.expression.line }
          lines = exprs_lines.group_by { |i| i }

          # every line with more than 1 expression on it is an offence
          lines.each do |line, expr_on_line|
            add_offence(:convention, line, MSG) if expr_on_line.size > 1
          end
        end

        # not pretty reliable, but the best we can do for now
        source.each_with_index do |line, index|
          add_offence(:convention, index, MSG) if line =~ /;\s*\z/
        end
      end
    end
  end
end
