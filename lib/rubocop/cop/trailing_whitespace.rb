module Rubocop
  module Cop
    class TrailingWhitespace < Cop
      ERROR_MESSAGE = 'Trailing whitespace detected.'

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index, line, ERROR_MESSAGE) if line =~ /.*[ \t]+$/
        end
      end
    end
  end
end
