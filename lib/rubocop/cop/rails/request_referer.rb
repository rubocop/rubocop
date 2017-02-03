# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for consistent uses of request.referrer or
      # request.referrer, depending on configuration.
      class RequestReferer < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `request.%s` instead of `request.%s`.'.freeze

        def_node_matcher :referer?, <<-PATTERN
          (send (send nil :request) {:referer :referrer})
        PATTERN

        def on_send(node)
          referer?(node) do
            return unless node.method?(wrong_method_name)

            add_offense(node.source_range, node.source_range, message)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node, "request.#{style}") }
        end

        private

        def message
          format(MSG, style, wrong_method_name)
        end

        def wrong_method_name
          style == :referer ? :referrer : :referer
        end
      end
    end
  end
end
