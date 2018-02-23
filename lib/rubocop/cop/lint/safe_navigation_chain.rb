# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # The safe navigation operator returns nil if the receiver is
      # nil.  If you chain an ordinary method call after a safe
      # navigation operator, it raises NoMethodError.  We should use a
      # safe navigation operator after a safe navigation operator.
      # This cop checks for the problem outlined above.
      #
      # @example
      #
      #   # bad
      #
      #   x&.foo.bar
      #   x&.foo + bar
      #   x&.foo[bar]
      #
      # @example
      #
      #   # good
      #
      #   x&.foo&.bar
      #   x&.foo || bar
      class SafeNavigationChain < Cop
        include NilMethods
        extend TargetRubyVersion

        MSG = 'Do not chain ordinary method call' \
              ' after safe navigation operator.'.freeze

        def_node_matcher :bad_method?, <<-PATTERN
          (send (csend ...) $_ ...)
        PATTERN

        minimum_target_ruby_version 2.3

        def on_send(node)
          bad_method?(node) do |method|
            return if nil_methods.include?(method)

            loc = node.loc.dot || :selector

            add_offense(node, location: loc)
          end
        end

        def autocorrect(node)
          dot = node.loc.dot

          return unless dot

          lambda do |corrector|
            corrector.insert_before(dot, '&')
          end
        end
      end
    end
  end
end
