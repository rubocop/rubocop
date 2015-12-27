# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      class SafeNavigationOperator < Cop
        MSG = 'Prefer `&.` over `ActiveSupport#try!`.'

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless method_name == :try! && args.length > 0
          add_offense(node, :selector)
        end
      end
    end
  end
end
