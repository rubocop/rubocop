# encoding: utf-8

module Rubocop
  module Cop
    module IfThenElse
      def on_if(node)
        check(node)
        super
      end

      def on_unless(node)
        check(node)
        super
      end

      def check(node)
        # We won't check modifier or ternary conditionals.
        if node.src.expression.to_source =~ /\A(if|unless)\b/
          lineno = offending_line(node)
          add_offence(:convention, lineno, error_message) if lineno
        end
      end
    end

    class IfWithSemicolon < Cop
      include IfThenElse

      def offending_line(node)
        if node.src.begin && node.src.begin.to_source == ';'
          node.src.begin.line
        end
      end

      def error_message
        'Never use if x; Use the ternary operator instead.'
      end
    end

    class MultilineIfThen < Cop
      include IfThenElse

      def offending_line(node)
        if node.src.expression.to_source =~ /\bthen\s*(#.*)?\s*$/
          node.src.begin.line
        end
      end

      def error_message
        'Never use then for multi-line if/unless.'
      end
    end

    class OneLineConditional < Cop
      include IfThenElse

      def offending_line(node)
        node.src.expression.line unless node.src.expression.to_source =~ /\n/
      end

      def error_message
        'Favor the ternary operator (?:) over if/then/else/end constructs.'
      end
    end
  end
end
