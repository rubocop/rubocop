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
        MSG = 'Use `#%<type>s_type?` to check node type.'.freeze

        def_node_matcher :node_type_check, <<-PATTERN
          (send (send $_ :type) :== (sym $_))
        PATTERN

        def on_send(node)
          node_type_check(node) do |_receiver, node_type|
            return unless Parser::Meta::NODE_TYPES.include?(node_type)

            add_offense(node, message: format(MSG, type: node_type))
          end
        end

        def autocorrect(node)
          receiver, node_type = node_type_check(node)
          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            receiver.loc.expression.end_pos + 1,
                                            node.loc.expression.end_pos)

          lambda do |corrector|
            corrector.replace(range, "#{node_type}_type?")
          end
        end
      end
    end
  end
end
