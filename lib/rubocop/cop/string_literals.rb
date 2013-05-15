# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      ERROR_MESSAGE = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        full_source = source.join($RS)
        on_node(:str, sexp, :dstr) do |s|
          text = s.to_a[0]

          if text !~ /['\n\t\r]/ &&
              full_source[s.src.expression.begin_pos][0] == '"'
            add_offence(:convention,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
