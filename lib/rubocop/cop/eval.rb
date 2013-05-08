# encoding: utf-8

module Rubocop
  module Cop
    class Eval < Cop
      ERROR_MESSAGE = 'The use of eval is a serious security risk.'

      def inspect(file, source, tokens, sexp)
        each(:command, sexp) { |s| process_ident(s[1]) }
        each(:fcall, sexp) { |s| process_ident(s[1]) }
      end

      def process_ident(sexp)
        if sexp[0] == :@ident && sexp[1] == 'eval'
          add_offence(:security,
                      sexp[2].lineno,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
