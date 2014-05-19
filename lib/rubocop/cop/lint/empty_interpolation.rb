# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for empty interpolation.
      #
      # @example
      #
      #   "result is #{}"
      class EmptyInterpolation < Cop
        MSG = 'Empty interpolation detected.'
        private_constant :MSG

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            next unless begin_node.children.empty?
            add_offense(begin_node, :expression, MSG)
          end
        end
      end
    end
  end
end
