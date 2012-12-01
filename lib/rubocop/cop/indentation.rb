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
      def each_when(sexp, case_ix = -1)
        case_ix += 1 if sexp[0] == :case
        yield case_ix if sexp[0] == :when
        sexp.grep(Array).each do |s|
          each_when(s, case_ix) { |cix| yield cix }
        end
      end
    end
  end
end
