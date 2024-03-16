# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class InfiniteLoopDuringAutocorrectCop < RuboCop::Cop::Base
        extend AutoCorrector

        def on_class(node)
          add_offense(node, message: 'Class must be a Module') do |corrector|
            # Replace the offense with itself, will be picked up again next loop
            corrector.replace(node, node.source)
          end
        end
      end
    end
  end
end
