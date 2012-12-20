# encoding: utf-8

module Rubocop
  module Cop
    class Indentation < Cop
      ERROR_MESSAGE = 'Indent when as deep as case.'

      def inspect(file, source, tokens, sexp)
        case_tokens = find_keywords(tokens, 'case')
        when_tokens = find_keywords(tokens, 'when')
        each_when(sexp) { |case_ix|
          when_pos = when_tokens.shift[0]
          if when_pos[1] != case_tokens[case_ix][0][1]
            index = when_pos[0] - 1
            add_offence(:convention, index, source[index], ERROR_MESSAGE)
          end
        }
      end

      def find_keywords(tokens, keyword)
        indexes = tokens.each_index.find_all { |ix|
          keyword?(tokens, ix, keyword)
        }
        tokens.values_at(*indexes)
      end

      def keyword?(tokens, ix, keyword)
        tokens[ix][1..-1] == [:on_kw, keyword] &&
          tokens[ix - 1][1] != :on_symbeg
      end

      # Does a depth first search for :when, yielding the index of the
      # corresponding :case for each one.
      def each_when(sexp, case_ix = -1, &block)
        case sexp[0]
        when :case
          case_ix += 1
          case_ix = next_when(sexp, case_ix, &block)
        when :when
          yield case_ix
          all_except_when = sexp.grep(Array).find_all { |s| s[0] != :when }
          case_ix_deep = each_when(all_except_when, case_ix, &block)
          case_ix_next = next_when(sexp, case_ix, &block)
          case_ix = (case_ix_next == case_ix) ? case_ix_deep : case_ix_next
        else
          sexp.grep(Array).each { |s| case_ix = each_when(s, case_ix, &block) }
        end
        case_ix
      end

      def next_when(sexp, case_ix, &block)
        nxt = sexp.grep(Array).find { |s| s[0] == :when } or return case_ix
        each_when(nxt, case_ix, &block)
      end
    end
  end
end
