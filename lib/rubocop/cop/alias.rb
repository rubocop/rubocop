# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      MSG = 'Use alias_method instead of alias.'

      def on_alias(node)
        add_offence(:convention,
                    node.loc.keyword.line,
                    MSG)

        super
      end
    end
  end
end
