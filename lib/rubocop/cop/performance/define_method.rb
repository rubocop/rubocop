# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `module_eval` and suggest
      # changing them to `define_method`.
      class DefineMethod < Cop
        MSG = 'Use `define_method` instead of `module_eval`.'

        def on_send(node)
          _, method, _ = *node

          return unless method == :module_eval

          add_offense(node, node.loc.selector)
        end
      end
    end
  end
end
