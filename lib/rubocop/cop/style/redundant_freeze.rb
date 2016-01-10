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

        def on_send(node)
          receiver, method_name, *args = *node

          return unless receiver &&
                        method_name == :freeze &&
                        args.empty? &&
                        receiver.immutable_literal?

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
