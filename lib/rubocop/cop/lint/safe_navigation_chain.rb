# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Safe navigation operator returns nil if the receiver is nil.
      # So if you chain an ordinary method call after safe navigation operator,
      # it raises NoMethodError.
      # We should use safe navigation operator after safe navigation operator.
      # This cop checks the problem.
      #
      # @example
      #   # bad
      #   x&.foo.bar
      #   x&.foo + bar
      #   x&.foo[bar]
      #
      #   # good
      #   x&.foo&.bar
      #   x&.foo || bar
      class SafeNavigationChain < Cop
        MSG = 'Do not chain ordinary method call' \
          ' after safe navigation operator.'.freeze

        def_node_matcher :bad_method?, <<-PATTERN
          (send (csend ...) $_ ...)
        PATTERN

        def on_send(node)
          return if target_ruby_version < 2.3

          bad_method?(node) do |method|
            return if nil_methods.include?(method)

            loc = node.loc.dot || :selector
            add_offense(node, loc)
          end
        end

        def autocorrect(node)
          dot = node.loc.dot
          return unless node.loc.dot

          lambda do |corrector|
            corrector.insert_before(dot, '&')
          end
        end

        private

        def nil_methods
          nil.methods + %i(present? blank?)
        end
      end
    end
  end
end
