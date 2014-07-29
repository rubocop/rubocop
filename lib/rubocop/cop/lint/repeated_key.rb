# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # Check for the same key being repeated in a literal hash
      class RepeatedKey < Cop
        MSG = 'Repeated hash key'

        def on_hash(node)
          key_nodes = node.children.map do |pair_node|
            key_node, _value_node = pair_node.children
            key_node
          end
          return if key_nodes.combination(2).none? do |k1, k2|
                      k1 == k2
                    end
          # FIXME: Location is wrong.
          add_offense(node, :expression)
        end
      end
    end
  end
end
