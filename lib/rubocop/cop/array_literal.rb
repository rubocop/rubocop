# encoding: utf-8

module Rubocop
  module Cop
    class ArrayLiteral < Cop
      MSG = 'Use array literal [] instead of Array.new.'

      # We're interested in the following AST:
      # (send
      #   (const nil :Array) :new)
      TARGET = s(:send, s(:const, nil, :Array), :new)

      def inspect(file, source, tokens, ast)
        on_node(:send, ast, :block) do |node|
          if node == TARGET
            add_offence(:convention,
                        node.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
