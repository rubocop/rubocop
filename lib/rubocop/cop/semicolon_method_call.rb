# encoding: utf-8

module Rubocop
  module Cop
    class SemicolonMethodCall < Cop
      ERROR_MESSAGE = 'Do not use :: for method invocation.'

      def inspect(file, source, tokens, sexp)
        each(:call, sexp) do |s|
          add_offence(:convention,
                      all_positions(s).first.lineno,
                      ERROR_MESSAGE) if s[2].to_s == '::'
        end
      end
    end
  end
end
