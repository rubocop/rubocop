# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class BeginBlock < Cop
        MSG = 'Avoid the use of BEGIN blocks.'

        def on_preexe(node)
          add_offence(node, :keyword)
        end
      end
    end
  end
end
