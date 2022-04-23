# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop suggests `ENV.fetch` for the replacement of `ENV[]`.
      # `ENV[]` silently fails and returns `nil` when the environment variable is unset,
      # which may cause unexpected behaviors when the developer forgets to set it.
      # On the other hand, `ENV.fetch` raises KeyError or returns the explicitly
      # specified default value.
      #
      # @example
      #   # bad
      #   ENV['X']
      #   ENV['X'] || z
      #   x = ENV['X']
      #
      #   # good
      #   ENV.fetch('X')
      #   ENV.fetch('X', nil) || z
      #   x = ENV.fetch('X')
      #
      #   # also good
      #   !ENV['X']
      #   ENV['X'].some_method # (e.g. `.nil?`)
      #
      class FetchEnvVar < Base
        extend AutoCorrector

        MSG = 'Use `ENV.fetch(%<key>s)` or `ENV.fetch(%<key>s, nil)` instead of `ENV[%<key>s]`.'

        # @!method env_with_bracket?(node)
        def_node_matcher :env_with_bracket?, <<~PATTERN
          (send (const nil? :ENV) :[] $_)
        PATTERN

        def on_send(node)
          env_with_bracket?(node) do |expression|
            break if allowed_var?(expression)
            break if allowable_use?(node)

            add_offense(node, message: format(MSG, key: expression.source)) do |corrector|
              corrector.replace(node, "ENV.fetch(#{expression.source}, nil)")
            end
          end
        end

        private

        def allowed_var?(expression)
          expression.str_type? && cop_config['AllowedVars'].include?(expression.value)
        end

        def used_as_flag?(node)
          return false if node.root?

          node.parent.if_type? || (node.parent.send_type? && node.parent.prefix_bang?)
        end

        # Check if the node is a receiver and receives a message with dot syntax.
        def message_chained_with_dot?(node)
          return false if node.root?

          node.parent.send_type? && node.parent.children.first == node && node.parent.dot?
        end

        # The following are allowed cases:
        #
        # - Used as a flag (e.g., `if ENV['X']` or `!ENV['X']`) because
        #   it simply checks whether the variable is set.
        # - Receiving a message with dot syntax, e.g. `ENV['X'].nil?`.
        # - `ENV['key']` assigned by logical AND/OR assignment.
        def allowable_use?(node)
          used_as_flag?(node) || message_chained_with_dot?(node) || assigned?(node)
        end

        # The following are allowed cases:
        #
        # - `ENV['key']` is a receiver of `||=`, e.g. `ENV['X'] ||= y`.
        # - `ENV['key']` is a receiver of `&&=`, e.g. `ENV['X'] &&= y`.
        def assigned?(node)
          return false unless (parent = node.parent)&.assignment?

          lhs, _method, _rhs = *parent
          node == lhs
        end
      end
    end
  end
end
