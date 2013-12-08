# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for *when;* uses in *case* expressions.
      class WhenThen < Cop
        MSG = 'Never use "when x;". Use "when x then" instead.'

        def on_when(node)
          if node.loc.begin && node.loc.begin.is?(';')
            add_offence(node, :begin)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, ' then')
          end
        end
      end
    end
  end
end
