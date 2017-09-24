# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for BEGIN blocks.
      class BeginBlock < Cop
        MSG = 'Avoid the use of `BEGIN` blocks.'.freeze

        def on_preexe(node)
          add_offense(node, location: :keyword)
        end
      end
    end
  end
end
