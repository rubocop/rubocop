# encoding: utf-8

module Rubocop
  module Cop
    module IfThenElse
      def inspect(file, source, tokens, ast)
        on_node([:if, :unless], ast) do |if_node|
          lineno = offending_line(if_node)
          add_offence(:convention, lineno, error_message) if lineno
        end
      end
    end

    class IfWithSemicolon < Cop
      include IfThenElse

      def offending_line(if_node)
        if if_node.src.begin && if_node.src.begin.to_source == ';'
          if_node.src.begin.line
        end
      end

      def error_message
        'Never use if x; Use the ternary operator instead.'
      end
    end

    class MultilineIfThen < Cop
      include IfThenElse

      def offending_line(if_node)
        if if_node.src.expression.to_source =~ /\bthen\s*(#.*)?\s*$/
          if_node.src.begin.line
        end
      end

      def error_message
        'Never use then for multi-line if/unless.'
      end
    end

    class OneLineConditional < Cop
      include IfThenElse

      def offending_line(if_node)
        if_node.src.begin.line unless if_node.src.expression.to_source =~ /\n/
      end

      def error_message
        'Favor the ternary operator (?:) over if/then/else/end constructs.'
      end
    end
  end
end
