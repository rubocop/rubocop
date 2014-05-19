# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class BeginBlock < Cop
        MSG = 'Avoid the use of `BEGIN` blocks.'
        private_constant :MSG

        def on_preexe(node)
          add_offense(node, :keyword, MSG)
        end
      end
    end
  end
end
