# encoding: utf-8

module Rubocop
  module Cop
    class Not < Cop
      MSG = 'Use ! instead of not.'

      def on_send(node)
        _receiver, method_name, *args = *node

        # not does not take any arguments
        if args.empty? && method_name == :! &&
            node.loc.selector.source == 'not'
          add_offence(:convention, node.loc, MSG)
        end

        super
      end
    end
  end
end
