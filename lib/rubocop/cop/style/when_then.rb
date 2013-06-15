# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class WhenThen < Cop
        MSG = 'Never use "when x;". Use "when x then" instead.'

        def on_when(node)
          if node.loc.begin && node.loc.begin.source == ';'
            add_offence(:convention, node.loc.expression, MSG)
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
