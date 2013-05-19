# encoding: utf-8

module Rubocop
  module Cop
    class NumericLiterals < Cop
      MSG = 'Add underscores to large numeric literals to ' +
        'improve their readability.'

      def inspect(file, source, tokens, ast)
        on_node([:int, :float], ast) do |s|
          if s.to_a[0] > 10000 &&
              s.src.expression.to_source.split('.').grep(/\d{6}/).any?
            add_offence(:convention, s.src.expression.line, MSG)
          end
        end
      end
    end
  end
end
