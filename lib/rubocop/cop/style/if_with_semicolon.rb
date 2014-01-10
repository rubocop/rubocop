# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of semicolon in if statements.
      class IfWithSemicolon < Cop
        include IfThenElse

        def offending_line(node)
          node.loc.begin.line if node.loc.begin && node.loc.begin.is?(';')
        end

        def error_message(_node)
          'Never use if x; Use the ternary operator instead.'
        end
      end
    end
  end
end
