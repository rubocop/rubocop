# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class ClassMustBeAModuleCop < RuboCop::Cop::Base
        extend AutoCorrector

        def on_class(node)
          add_offense(node, message: 'Class must be a Module') do |corrector|
            corrector.replace(node.loc.keyword, 'module')
          end
        end
      end
    end
  end
end
