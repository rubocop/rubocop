# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for consistent uses of `request.referer` or
      # `request.referrer`, depending on the cop's configuration.
      #
      # @example EnforcedStyle: referer (default)
      #   # bad
      #   request.referrer
      #
      #   # good
      #   request.referer
      #
      # @example EnforcedStyle: referrer
      #   # bad
      #   request.referer
      #
      #   # good
      #   request.referrer
      class RequestReferer < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `request.%<prefer>s` instead of ' \
              '`request.%<current>s`.'.freeze

        def_node_matcher :referer?, <<-PATTERN
          (send (send nil? :request) {:referer :referrer})
        PATTERN

        def on_send(node)
          referer?(node) do
            return unless node.method?(wrong_method_name)

            add_offense(node.source_range, location: node.source_range)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node, "request.#{style}") }
        end

        private

        def message(_node)
          format(MSG, prefer: style, current: wrong_method_name)
        end

        def wrong_method_name
          style == :referer ? :referrer : :referer
        end
      end
    end
  end
end
