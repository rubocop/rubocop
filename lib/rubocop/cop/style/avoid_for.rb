# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of the *for* keyword.
      class AvoidFor < Cop
        MSG = 'Prefer *each* over *for*.'

        def on_for(node)
          add_offence(:convention, node.loc.keyword, MSG)

          super
        end
      end
    end
  end
end
