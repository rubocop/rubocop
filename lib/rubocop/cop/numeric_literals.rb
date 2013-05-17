# encoding: utf-8

module Rubocop
  module Cop
    class NumericLiterals < Cop
      ERROR_MESSAGE = 'Add underscores to large numeric literals to ' +
        'improve their readability.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node([:int, :float], sexp) do |s|
          if s.to_a[0] > 10000 &&
              s.src.expression.to_source.split('.').grep(/\d{6}/).any?
            add_offence(:convention, s.src.expression.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
