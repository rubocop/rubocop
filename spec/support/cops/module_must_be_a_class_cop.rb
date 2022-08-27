# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class ModuleMustBeAClassCop < RuboCop::Cop::Base
        extend AutoCorrector

        def on_module(node)
          add_offense(node, message: 'Module must be a Class') do |corrector|
            corrector.replace(node.loc.keyword, 'class')
          end
        end
      end
    end
  end
end
