# encoding: utf-8

module Rubocop
  module Cop
    class HashLiteral < Cop
      ERROR_MESSAGE = 'Use hash literal {} instead of Hash.new.'

      # We're interested in the following AST:
      # (send
      #   (const nil :Hash) :new)
      TARGET = s(:send, s(:const, nil, :Hash), :new)

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:send, sexp, :block) do |s|
          if s == TARGET
            add_offence(:convention,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
