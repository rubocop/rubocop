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
        if node.loc.expression.source =~ /\A(if|unless)\b/
          lineno = offending_line(node)
          add_offence(:convention, lineno, error_message) if lineno
        end
      end
    end

    class IfWithSemicolon < Cop
      include IfThenElse

      def offending_line(node)
        if node.loc.begin && node.loc.begin.source == ';'
          node.loc.begin.line
        end
      end

      def error_message
        'Never use if x; Use the ternary operator instead.'
      end
    end

    class MultilineIfThen < Cop
      include IfThenElse

      def offending_line(node)
        if node.loc.expression.source =~ /\bthen\s*(#.*)?\s*$/
          node.loc.begin.line
        end
      end

      def error_message
        'Never use then for multi-line if/unless.'
      end
    end

    class OneLineConditional < Cop
      include IfThenElse

      def offending_line(node)
        node.loc.expression.line unless node.loc.expression.source =~ /\n/
      end

      def error_message
        'Favor the ternary operator (?:) over if/then/else/end constructs.'
      end
    end
  end
end
