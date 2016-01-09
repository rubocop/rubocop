# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for END blocks in method definitions.
      class EndInMethod < Cop
        MSG = '`END` found in method definition. Use `at_exit` instead.'.freeze

        def on_postexe(node)
          inside_of_method = node.each_ancestor(:def, :defs).count.nonzero?
          add_offense(node, :keyword) if inside_of_method
        end
      end
    end
  end
end
