# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that Rails.env is compared using `.production?`-like
      # methods instead of equality against a string or symbol.
      #
      # @example
      #   # bad
      #   Rails.env == 'production'
      #
      #   # bad, always returns false
      #   Rails.env == :test
      #
      #   # good
      #   Rails.env.production?
      class EnvironmentComparison < Cop
        MSG = 'Favor `Rails.env.%s?` over `Rails.env == %s`.'.freeze

        def_node_matcher :environment_comparison?, <<-PATTERN
          (send
            (send (const {nil? cbase} :Rails) :env)
            :==
            {str sym}
          )
        PATTERN

        def on_send(node)
          return unless environment_comparison?(node)
          env = node.children.last
          add_offense(node,
                      message: format(MSG, env.children.first, env.source))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        private

        def replacement(node)
          "#{node.receiver.source}.#{node.children.last.children.first}?"
        end
      end
    end
  end
end
