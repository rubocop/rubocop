# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for comparison of something with itself.
      #
      # @example
      #
      #   # bad
      #
      #   x.top >= x.top
      class UselessComparison < Cop
        MSG = 'Comparison of something with itself detected.'.freeze
        OPS = %w[== === != < > <= >= <=>].freeze

        def_node_matcher :useless_comparison?,
                         "(send $_match {:#{OPS.join(' :')}} $_match)"

        def on_send(node)
          return unless useless_comparison?(node)

          add_offense(node, :selector)
        end
      end
    end
  end
end
