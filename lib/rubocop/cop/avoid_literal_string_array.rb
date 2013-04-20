# encoding: utf-8

module Rubocop
  module Cop
    class AvoidLiteralStringArray < Cop
      ERROR_MESSAGE = 'Prefer %w() over literal array syntax for an array of' +
        ' strings.'
      LITERAL_ARRAY_REGEX = /^?[ =>]\[(('|")[^('|")]+('|")(, ?)?)+\]/

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, ERROR_MESSAGE) if line =~
            LITERAL_ARRAY_REGEX
        end
      end
    end
  end
end
