# encoding: utf-8

module Rubocop
  module Cop
    class CaseIndentation < Cop
      ERROR_MESSAGE = 'Indent when as deep as case.'

      def inspect(file, source, tokens, sexp)
        case_tokens = find_keywords(tokens, 'case')
        when_tokens = find_keywords(tokens, 'when')
        each_when(sexp) do |case_ix|
          when_pos = when_tokens.shift.pos
          if when_pos.column != case_tokens[case_ix].pos.column
            add_offence(:convention, when_pos.lineno, ERROR_MESSAGE)
          end
        end
      end

      def find_keywords(tokens, keyword)
        indexes = tokens.each_index.select do |ix|
          keyword?(tokens, ix, keyword)
        end
        tokens.values_at(*indexes)
      end

      def keyword?(tokens, ix, keyword)
        [tokens[ix].type, tokens[ix].text] == [:on_kw, keyword] &&
          tokens[ix - 1].type != :on_symbeg
      end

      # Does a depth first search for :when, yielding the index of the
      # corresponding :case for each one.
      def each_when(sexp, case_ix = -1, &block)
        if sexp[0] == :case
          @total_case_ix = (@total_case_ix || -1) + 1
          each_when(sexp[2], @total_case_ix, &block)
        else
          yield case_ix if sexp[0] == :when
          sexp.grep(Array).each { |s| each_when(s, case_ix, &block) }
        end
      end
    end
  end
end
