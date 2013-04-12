# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      ERROR_MESSAGE = "Prefer each over for."

      def inspect(file, source, tokens, sexp)
        each(:for, sexp) do |s|
          puts s.inspect

          add_offence(:convention,
                      s[1][1][2].lineno,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
