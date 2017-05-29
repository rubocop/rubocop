# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that node types are checked using the predicate helpers.
      #
      # @example
      #
      #   # bad
      #   node.type == :send
      #
      #   # good
      #   node.send_type?
      #
      class NodeTypePredicate < Cop
        MSG = 'Use `#%s_type?` to check node type.'.freeze

        def_node_search :node_type_check, <<-PATTERN
          (send (send _ :type) :== (sym $_))
        PATTERN

        def on_send(node)
          node_type_check(node) do |node_type|
            return unless Parser::Meta::NODE_TYPES.include?(node_type)

            add_offense(node, :expression, format(MSG, node_type))
          end
        end
      end
    end
  end
end
