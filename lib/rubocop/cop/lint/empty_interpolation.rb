# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for empty interpolation.
      #
      # @example
      #
      #   "result is #{}"
      class EmptyInterpolation < Cop
        MSG = 'Empty interpolation detected.'.freeze

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            add_offense(begin_node, :expression) if begin_node.children.empty?
          end
        end
      end
    end
  end
end
