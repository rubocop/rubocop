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
      class StringConversionInInterpolation < Cop
        include Interpolation

        MSG_DEFAULT = 'Redundant use of `Object#to_s` in interpolation.'
        MSG_SELF = 'Use `self` instead of `Object#to_s` in ' \
                   'interpolation.'

        def_node_matcher :to_s_without_args?, '(send _ :to_s)'

        def on_interpolation(begin_node)
          final_node = begin_node.children.last

          return unless to_s_without_args?(final_node)

          add_offense(final_node, location: :selector)
        end

        def autocorrect(node)
          lambda do |corrector|
            receiver = node.receiver
            corrector.replace(
              node.source_range,
              if receiver
                receiver.source
              else
                'self'
              end
            )
          end
        end

        private

        def message(node)
          node.receiver ? MSG_DEFAULT : MSG_SELF
        end
      end
    end
  end
end
