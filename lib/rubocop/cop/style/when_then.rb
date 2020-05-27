# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for `when;` uses in `case` expressions.
      #
      # @example
      #   # bad
      #   case foo
      #   when 1; 'baz'
      #   when 2; 'bar'
      #   end
      #
      #   # good
      #   case foo
      #   when 1 then 'baz'
      #   when 2 then 'bar'
      #   end
      class WhenThen < Cop
        MSG = 'Do not use `when x;`. Use `when x then` instead.'

        def on_when(node)
          return if node.multiline? || node.then? || !node.body

          add_offense(node, location: :begin)
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
