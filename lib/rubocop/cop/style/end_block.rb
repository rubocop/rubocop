# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class EndBlock < Cop
        MSG = 'Avoid the use of END blocks. Use `Kernel#at_exit` instead.'

        def on_postexe(node)
          add_offence(:convention, node.loc.expression, MSG)

          super
        end
      end
    end
  end
end
