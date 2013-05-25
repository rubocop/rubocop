# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      MSG = 'Prefer *each* over *for*.'

      def on_for(node)
        add_offence(:convention,
                    node.loc.keyword.line,
                    MSG)

        super
      end
    end
  end
end
