# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      MSG = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def on_str(node)
        text, = *node
        exp = node.loc.expression

        if text !~ /['\n\t\r]/ && exp.source[0] == '"'
          add_offence(:convention, node.loc.line, MSG)
        end
      end

      alias_method :on_dstr, :ignore_node
      alias_method :on_regexp, :ignore_node
    end
  end
end
