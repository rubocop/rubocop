# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      # This cop is only used to test infinite loop detection
      class BtoA < RuboCop::Cop::Base
        extend AutoCorrector

        def on_class(node)
          return unless node.loc.name.source.include?('B')

          add_offense(node.loc.name, message: 'B to A') do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_module on_class

        private

        def autocorrect(corrector, node)
          corrector.replace(node.loc.name, node.loc.name.source.tr('B', 'A'))
        end
      end
    end
  end
end
