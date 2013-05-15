# encoding: utf-8

module Rubocop
  module Cop
    class UnlessElse < Cop
      ERROR_MESSAGE = 'Never use unless with else. Rewrite these with the ' +
        'positive case first.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:if, sexp) do |s|
          src = s.src

          # discard ternary ops and modifier if/unless nodes
          next unless src.respond_to?(:keyword) && src.respond_to?(:else)

          if src.keyword.to_source == 'unless' && src.else
            add_offence(:convention, src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
