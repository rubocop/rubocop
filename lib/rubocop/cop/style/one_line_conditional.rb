# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # TODO: Make configurable.
      # Checks for uses of if/then/else/end on a single line.
      class OneLineConditional < Cop
        include IfThenElse

        def offending_line(node)
          node.loc.expression.line unless node.loc.expression.source =~ /\n/
        end

        def error_message(_node)
          'Favor the ternary operator (?:) over if/then/else/end constructs.'
        end
      end
    end
  end
end
