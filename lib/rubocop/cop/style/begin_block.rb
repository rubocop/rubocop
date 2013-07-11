# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class BeginBlock < Cop
        MSG = 'Avoid the use of BEGIN blocks.'

        def on_preexe(node)
          add_offence(:convention, node.loc.keyword, MSG)
        end
      end
    end
  end
end
