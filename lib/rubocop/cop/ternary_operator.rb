# encoding: utf-8

module Rubocop
  module Cop
    class TernaryOperator < Cop
      ERROR_MESSAGE = 'Avoid multi-line ?: (the ternary operator); use ' +
        'if/unless instead.'

      def inspect(file, source, tokens, sexp)
        each(:ifop, sexp) do |ifop|
          line_numbers = all_positions(ifop).map(&:lineno)
          if line_numbers.uniq.size > 1
            add_offence(:convention, line_numbers[0], ERROR_MESSAGE)
          end
        end
      end

      def all_positions(sexp)
        return [sexp[2]] if sexp[0] =~ /^@/
        sexp.grep(Array).inject([]) { |memo, s| memo + all_positions(s) }
      end
    end
  end
end
