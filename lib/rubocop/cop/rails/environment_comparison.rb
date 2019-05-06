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
        MSG = "Favor `Rails.env.%<env>s?` over `Rails.env == '%<env>s'`."

        SYM_MSG = 'Do not compare `Rails.env` with a symbol, it will always ' \
          'evaluate to `false`.'

        def_node_matcher :environment_str_comparison?, <<-PATTERN
          (send
            (send (const {nil? cbase} :Rails) :env)
            :==
            $str
          )
        PATTERN

        def_node_matcher :environment_sym_comparison?, <<-PATTERN
          (send
            (send (const {nil? cbase} :Rails) :env)
            :==
            $sym
          )
        PATTERN

        def on_send(node)
          environment_str_comparison?(node) do |env_node|
            env, = *env_node
            add_offense(node, message: format(MSG, env: env))
          end
          environment_sym_comparison?(node) do |_|
            add_offense(node, message: SYM_MSG)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        private

        def replacement(node)
          "#{node.receiver.source}.#{content(node.first_argument)}?"
        end

        def_node_matcher :content, <<-PATTERN
          ({str sym} $_)
        PATTERN
      end
    end
  end
end
