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
          if s.src.keyword.to_source == 'unless' && s.src.else
            add_offence(:convention, s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
