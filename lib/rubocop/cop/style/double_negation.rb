# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of double negation (`!!`) to convert something to a boolean value.
      #
      # When using `EnforcedStyle: allowed_in_returns`, allow double negation in contexts
      # that use boolean as a return value. When using `EnforcedStyle: forbidden`, double negation
      # should be forbidden always.
      #
      # @example
      #   # bad
      #   !!something
      #
      #   # good
      #   !something.nil?
      #
      # @example EnforcedStyle: allowed_in_returns (default)
      #   # good
      #   def foo?
      #     !!return_value
      #   end
      #
      # @example EnforcedStyle: forbidden
      #   # bad
      #   def foo?
      #     !!return_value
      #   end
      #
      # Please, note that when something is a boolean value
      # !!something and !something.nil? are not the same thing.
      # As you're unlikely to write code that can accept values of any type
      # this is rarely a problem in practice.
      class DoubleNegation < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG = 'Avoid the use of double negation (`!!`).'
        RESTRICT_ON_SEND = %i[!].freeze

        # @!method double_negative?(node)
        def_node_matcher :double_negative?, '(send (send _ :!) :!)'

        def on_send(node)
          return unless double_negative?(node) && node.prefix_bang?
          return if style == :allowed_in_returns && allowed_in_returns?(node)

          location = node.loc.selector
          add_offense(location) do |corrector|
            corrector.remove(location)
            corrector.insert_after(node, '.nil?')
          end
        end

        private

        def allowed_in_returns?(node)
          node.parent&.return_type? || end_of_method_definition?(node)
        end

        def end_of_method_definition?(node)
          return false unless (def_node = find_def_node_from_ascendant(node))

          last_child = find_last_child(def_node.body)

          last_child.last_line == node.last_line
        end

        def find_def_node_from_ascendant(node)
          return unless (parent = node.parent)
          return parent if parent.def_type? || parent.defs_type?

          find_def_node_from_ascendant(node.parent)
        end

        def find_last_child(node)
          case node.type
          when :rescue
            find_last_child(node.body)
          when :ensure
            find_last_child(node.child_nodes.first)
          else
            node.child_nodes.last
          end
        end
      end
    end
  end
end
