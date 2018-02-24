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
        extend TargetRubyVersion

        MSG = 'Do not chain ordinary method call' \
              ' after safe navigation operator.'.freeze
        NIL_MSG = MSG + ' %<method>s is a method that `nil` responds to. ' \
          'This code might be relying on side effects, and ' \
          'it may not be safe for auto-correction.'.freeze
        NIL_METHODS = nil.methods.freeze

        def_node_matcher :bad_method?, <<-PATTERN
          (send (csend ...) $_ ...)
        PATTERN

        minimum_target_ruby_version 2.3

        def on_send(node)
          bad_method?(node) do |method|
            return if whitelist.include?(method)

            loc = node.loc.dot || :selector
            message = if NIL_METHODS.include?(method)
                        format(NIL_MSG, method: method)
                      else
                        MSG
                      end
            add_offense(node, location: loc, message: message)
          end
        end

        def autocorrect(node)
          dot = node.loc.dot

          return unless dot
          method = bad_method?(node)
          return if NIL_METHODS.include?(method)

          lambda do |corrector|
            corrector.insert_before(dot, '&')
          end
        end

        private

        def whitelist
          cop_config['Whitelist'].map(&:to_sym)
        end
      end
    end
  end
end
