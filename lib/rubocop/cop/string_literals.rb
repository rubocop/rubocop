# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      MSG = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def on_str(node)
        text, = *node

        if text !~ /['\n\t\r]/ && node.loc.begin.source == '"'
          add_offence(:convention, node.loc.line, MSG)
        end
      end

      alias_method :on_dstr, :ignore_node
      alias_method :on_regexp, :ignore_node
    end
  end
end
