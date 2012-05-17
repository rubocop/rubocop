module Rubocop
  module Cop
    class Tab < Cop
      ERROR_MESSAGE = 'Tab detected.'

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index, line, ERROR_MESSAGE) if line =~ /\t/
        end
      end
    end
  end
end
