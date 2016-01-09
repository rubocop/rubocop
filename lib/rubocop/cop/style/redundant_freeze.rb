# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop check for uses of Object#freeze on immutable objects.
      #
      # @example
      #   # bad
      #   CONST = 1.freeze
      #
      #   # good
      #   CONST = 1
      class RedundantFreeze < Cop
        MSG = 'Freezing immutable objects is pointless.'.freeze

        TARGET_NODES = [:int, :float, :sym, :dsym].freeze

        def on_send(node)
          receiver, method_name, *args = *node

          return unless receiver && TARGET_NODES.include?(receiver.type)
          return unless method_name == :freeze && args.empty?

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.dot)
            corrector.remove(node.loc.selector)
          end
        end
      end
    end
  end
end
