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
      class SafeNavigationChain < Cop
        include NilMethods

        MSG = 'Do not chain ordinary method call' \
              ' after safe navigation operator.'

        def_node_matcher :bad_method?, <<~PATTERN
          {
            (send $(csend ...) $_ ...)
            (send $(block (csend ...) ...) $_ ...)
          }
        PATTERN

        def on_send(node)
          bad_method?(node) do |safe_nav, method|
            return if nil_methods.include?(method)

            method_chain = method_chain(node)
            location =
              Parser::Source::Range.new(node.loc.expression.source_buffer,
                                        safe_nav.loc.expression.end_pos,
                                        method_chain.loc.expression.end_pos)
            add_offense(node, location: location)
          end
        end

        private

        def method_chain(node)
          chain = node
          while chain.send_type?
            chain = chain.parent if chain.parent &&
                                    %i[send csend].include?(chain.parent.type)
            break
          end
          chain
        end
      end
    end
  end
end
