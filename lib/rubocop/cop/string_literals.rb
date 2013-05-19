# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      MSG = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def inspect(file, source, tokens, ast)
        on_node(:str, ast, :dstr) do |s|
          text = s.to_a[0]

          if text !~ /['\n\t\r]/ && s.src.expression.to_source[0] == '"'
            add_offence(:convention,
                        s.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
