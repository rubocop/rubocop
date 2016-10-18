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

        OPS = %w[== === != < > <= >= <=>].freeze

        def on_send(node)
          # lambda.() does not have a selector
          return unless node.loc.selector

          op = node.loc.selector.source
          return unless OPS.include?(op)

          receiver, _method, args = *node
          add_offense(node, :selector) if receiver == args
        end
      end
    end
  end
end
