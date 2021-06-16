# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for string conversion in string interpolation,
      # which is redundant.
      #
      # @example
      #
      #   # bad
      #
      #   "result is #{something.to_s}"
      #
      # @example
      #
      #   # good
      #
      #   "result is #{something}"
      class RedundantStringCoercion < Base
        include Interpolation
        extend AutoCorrector

        MSG_DEFAULT = 'Redundant use of `Object#to_s` in interpolation.'
        MSG_SELF = 'Use `self` instead of `Object#to_s` in interpolation.'

        # @!method to_s_without_args?(node)
        def_node_matcher :to_s_without_args?, '(send _ :to_s)'

        def on_interpolation(begin_node)
          final_node = begin_node.children.last

          return unless to_s_without_args?(final_node)

          message = final_node.receiver ? MSG_DEFAULT : MSG_SELF

          add_offense(final_node.loc.selector, message: message) do |corrector|
            receiver = final_node.receiver
            corrector.replace(
              final_node,
              if receiver
                receiver.source
              else
                'self'
              end
            )
          end
        end
      end
    end
  end
end
