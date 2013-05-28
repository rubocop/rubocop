# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      MSG = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def inspect(source, tokens, ast, comments)
        on_node(:str, ast, [:dstr, :regexp]) do |node|
          text, = *node

          if text !~ /['\n\t\r]/ && node.loc.begin.source == '"'
            add_offence(:convention, node.loc.line, MSG)
          end
        end
      end
    end
  end
end
