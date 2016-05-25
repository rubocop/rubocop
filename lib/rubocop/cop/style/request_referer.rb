# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for consistent uses of request.referrer or
      # request.referrer, depending on configuration.
      class RequestReferer < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          if offense?(node)
            add_offense(node.source_range, node.source_range, message)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node, "request.#{style}") }
        end

        private

        def offense?(node)
          return false unless node.receiver
          receiver_name = node.receiver.method_name
          receiver_name == :request && node.method_name == wrong_method_name
        end

        def message
          "Use `request.#{style}` instead of `request.#{wrong_method_name}`."
        end

        def wrong_method_name
          style == :referer ? :referrer : :referer
        end
      end
    end
  end
end
