module Rubocop
  module Cop
    class Indentation < Cop
      ERROR_MESSAGE = "Indent when as deep as case."

      def inspect(file, source, tokens, sexp)
        case_tokens = tokens.find_all { |token| token.last == "case" }
        when_tokens = tokens.find_all { |token| token.last == "when" }
        each_when(sexp) { |case_ix|
          when_pos = when_tokens.shift[0]
          if when_pos[1] != case_tokens[case_ix][0][1]
            index = when_pos[0] - 1
            add_offence(:convention, index, source[index], ERROR_MESSAGE)
          end
        }
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
        nxt = sexp.find { |s| Array === s && s[0] == :when } or return case_ix
        each_when(nxt, case_ix, &block)
      end
    end
  end
end
