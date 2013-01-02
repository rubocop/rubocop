# encoding: utf-8

module Rubocop
  module Cop
    class Encoding < Cop
      ERROR_MESSAGE = 'Missing encoding comment.'
      MAX_LINE_LENGTH = 80

      def inspect(file, source, tokens, sexp)
        unless source[0] =~ /#.*coding: (UTF|utf)-8/
          message = sprintf(ERROR_MESSAGE)
          add_offence(:convention, 1, message)
        end
      end
    end
  end
end
