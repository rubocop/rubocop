# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for uses of semicolon in if statements.
      class IfWithSemicolon < Cop
        include IfThenElse

        def offending_line(node)
          b = node.loc.begin
          b.line if b && b.is?(';')
        end

        def error_message(_node)
          'Never use if x; Use the ternary operator instead.'
        end
      end
    end
  end
end
