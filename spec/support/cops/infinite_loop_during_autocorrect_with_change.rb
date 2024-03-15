# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class InfiniteLoopDuringAutocorrectWithChangeCop < RuboCop::Cop::Base
        extend AutoCorrector

        def on_class(node)
          add_offense(node, message: 'Class must be a Module') do |corrector|
            corrector.replace(node.loc.keyword, 'module')
          end
        end

        def on_module(node)
          add_offense(node, message: 'Module must be a Class') do |corrector|
            # Will register an offense during the next loop again
            corrector.replace(node, node.source)
          end
        end
      end
    end
  end
end
