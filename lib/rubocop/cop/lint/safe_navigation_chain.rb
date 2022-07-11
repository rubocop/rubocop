# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # The safe navigation operator returns nil if the receiver is
      # nil. If you chain an ordinary method call after a safe
      # navigation operator, it raises NoMethodError. We should use a
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
      class SafeNavigationChain < Base
        include NilMethods

        MSG = 'Do not chain ordinary method call after safe navigation operator.'

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          {
            (send $(csend ...) $_ ...)
            (send $({block numblock} (csend ...) ...) $_ ...)
          }
        PATTERN

        def on_send(node)
          bad_method?(node) do |safe_nav, method|
            return if nil_methods.include?(method)

            method_chain = method_chain(node)
            location =
              Parser::Source::Range.new(node.source_range.source_buffer,
                                        safe_nav.source_range.end_pos,
                                        method_chain.source_range.end_pos)
            add_offense(location)
          end
        end

        private

        def method_chain(node)
          chain = node
          chain = chain.parent if chain.send_type? && chain.parent&.call_type?
          chain
        end
      end
    end
  end
end
