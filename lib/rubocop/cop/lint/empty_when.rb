# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the presence of `when` branches without a body.
      #
      # @example
      #
      #   # bad
      #
      #   case foo
      #   when bar then 1
      #   when baz then # nothing
      #   end
      #
      # @example
      #
      #   # good
      #
      #   case foo
      #   when bar then 1
      #   when baz then 2
      #   end
      class EmptyWhen < Cop
        MSG = 'Avoid `when` branches without a body.'.freeze

        def on_case(node)
          node.each_when do |when_node|
            next if when_node.body

            add_offense(when_node, when_node.source_range, MSG)
          end
        end
      end
    end
  end
end
