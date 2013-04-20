# encoding: utf-8

module Rubocop
  module Cop
    class MethodLength < Cop
      ERROR_MESSAGE = 'Method has too many lines. [%d/%d]'

      def inspect(file, source, tokens, sexp)
        def_token_indices(tokens, source).each do |t_ix|
          def_lineno, end_lineno = def_and_end_lines(tokens, t_ix)
          length = source[def_lineno..(end_lineno - 2)].reject(&:empty?).size

          if length > MethodLength.max
            message = sprintf(ERROR_MESSAGE, length, MethodLength.max)
            add_offence(:convention, def_lineno, message)
          end
        end
      end

      def self.max
        MethodLength.config ? MethodLength.config['Max'] || 10 : 10
      end

      private

      def def_token_indices(tokens, source)
        tokens.each_index.select do |ix|
          # Need to check if the previous character is a ':'
          # to prevent matching ':def' symbols
          [tokens[ix].type, tokens[ix].text] == [:on_kw, 'def'] &&
            source[tokens[ix].pos.lineno - 1][tokens[ix].pos.column - 1] != ':'
        end
      end

      # Find the matching 'end' based on the indentation of 'def'
      # Fall back to last token if indentation cannot be matched
      def def_and_end_lines(tokens, t_ix)
        t1 = tokens[t_ix]
        t2 = tokens[(t_ix + 1)..-1].find(-> { tokens[-1] }) do |t|
          [t1.pos.column, t.type, t.text] == [t.pos.column, :on_kw, 'end']
        end
        [t1.pos.lineno, t2.pos.lineno]
      end
    end
  end
end
