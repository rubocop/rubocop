# encoding: utf-8

module Rubocop
  module Cop
    class ArrayLiteral < Cop
      ERROR_MESSAGE = 'Use array literal [] instead of Array.new.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp, :block) do |s|
          children = s.children

          # We're interested in the following AST:
          # (send
          #   (const nil :Array) :new)
          if children.size == 2 && children[0].type == :const &&
              children[0].to_a[1].to_s == 'Array' && children[1] == :new
            add_offence(:convention,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
