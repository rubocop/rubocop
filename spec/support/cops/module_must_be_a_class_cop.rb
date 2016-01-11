# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class ModuleMustBeAClassCop < RuboCop::Cop::Cop
        def on_module(node)
          add_offense(node, :expression, 'Module must be a Class')
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.keyword, 'class') }
        end
      end
    end
  end
end
