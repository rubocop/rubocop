# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class BeginBlock < Cop
        MSG = 'Avoid the use of `BEGIN` blocks.'.freeze

        def on_preexe(node)
          add_offense(node, :keyword)
        end
      end
    end
  end
end
