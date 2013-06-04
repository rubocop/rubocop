# encoding: utf-8

module Rubocop
  module Cop
    class Semicolon < Cop
      MSG = 'Do not use semicolons to terminate expressions.'

      def inspect(source, tokens, ast, comments)
        on_node(:begin, ast) do |node|
          exprs = node.children

          next if exprs.size < 2

          # create a map matching lines to the number of expressions on them
          exprs_lines = exprs.map { |e| e.loc.expression.line }
          lines = exprs_lines.group_by { |i| i }

          # every line with more than 1 expression on it is an offence
          lines.each do |line, expr_on_line|
            if expr_on_line.size > 1
              add_offence(:convention, Location.new(line, 0), MSG)
            end
          end
        end

        # not pretty reliable, but the best we can do for now
        source.each_with_index do |line, index|
          if line =~ /;\s*\z/
            add_offence(:convention, Location.new(index, line.length), MSG)
          end
        end
      end
    end
  end
end
