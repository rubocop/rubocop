# encoding: utf-8

module Rubocop
  module Cop
    module IfThenElse
      def inspect(file, source, tokens, sexp)
        # TODO
      end
    end

    class IfWithSemicolon < Cop
      include IfThenElse
      def error_message
        'Never use if x; Use the ternary operator instead.'
      end
    end

    class MultilineIfThen < Cop
      include IfThenElse
      def error_message
        'Never use then for multi-line if/unless.'
      end
    end

    class OneLineConditional < Cop
      include IfThenElse
      def error_message
        'Favor the ternary operator (?:) over if/then/else/end constructs.'
      end
    end
  end
end
