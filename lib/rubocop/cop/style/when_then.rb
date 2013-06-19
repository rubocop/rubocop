# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for *when;* uses in *case* expressions.
      class WhenThen < Cop
        MSG = 'Never use "when x;". Use "when x then" instead.'

        def on_when(node)
          if node.loc.begin && node.loc.begin.is?(';')
            add_offence(:convention, node.loc.begin, MSG)
            do_autocorrect(node)
          end

          super
        end

        def autocorrect_action(node)
          replace(node.loc.begin, ' then')
        end
      end
    end
  end
end
