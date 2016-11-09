# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for comparison of something with itself.
      #
      # @example
      #
      #  x.top >= x.top
      class UselessComparison < Cop
        MSG = 'Comparison of something with itself detected.'.freeze
        OPS = %w(== === != < > <= >= <=>).freeze

        def_node_matcher :comparison?, "(send $_ {:#{OPS.join(' :')}} $_)"

        def on_send(node)
          comparison?(node) do |receiver, args|
            add_offense(node, :selector) if receiver == args
          end
        end
      end
    end
  end
end
