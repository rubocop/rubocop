# encoding: utf-8

module RuboCop
  module Cop
    module Test
      class ClassMustBeAModuleCop < RuboCop::Cop::Cop
        def on_class(node)
          add_offense(node, :expression, 'Class must be a Module')
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.keyword, 'module')
          end
        end
      end
    end
  end
end
