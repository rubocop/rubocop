# encoding: utf-8

module Rubocop
  module Cop
    class DefWithParentheses < Cop
      def error_message
        "Omit the parentheses in defs when the method doesn't accept any " +
          'arguments.'
      end

      def inspect(file, source, tokens, sexp)
        on_node(:def, sexp) do |s|
          start_line = s.src.keyword.line
          end_line = s.src.end.line

          next if start_line == end_line

          _, args = *s
          if args.children == [] && args.src.begin
            add_offence(:convention, s.src.line, error_message)
          end
        end
      end
    end

    class DefWithoutParentheses < Cop
      def error_message
        'Use def with parentheses when there are arguments.'
      end

      def inspect(file, source, tokens, sexp)
        on_node(:def, sexp) do |s|
          _, args = *s
          if args.children.size > 0 && args.src.begin.nil?
            add_offence(:convention, s.src.line, error_message)
          end
        end
      end
    end
  end
end
