# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for *when;* uses in *case* expressions.
      class WhenThen < Cop
        MSG = 'Do not use `when x;`. Use `when x then` instead.'.freeze

        def on_when(node)
          return if node.multiline? || node.then? || !node.body

          add_offense(node, :begin)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.begin, ' then')
          end
        end
      end
    end
  end
end
