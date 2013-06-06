# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      MSG = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def on_str(node)
        text, = *node

        # Constants like __FILE__ and __DIR__ are created as strings,
        # but don't respond to begin.
        return unless node.loc.respond_to?(:begin)

        # regex matches IF there is a ' or there is a \\ in the string that is
        # not preceeded/followed by another \\ (e.g. `"\\x34"`) but not `"\\\\"`
        if text.inspect !~ /('|([^\\]|\A)\\([^\\]|\Z))/ && node.loc.begin.source == '"'
          add_offence(:convention, node.loc, MSG)
        end
      end

      alias_method :on_dstr, :ignore_node
      alias_method :on_regexp, :ignore_node
    end
  end
end
