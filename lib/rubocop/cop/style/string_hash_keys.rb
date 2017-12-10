# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of strings as keys in hashes. The use of
      # symbols is preferred instead.
      #
      # @example
      #   # bad
      #   { 'one' => 1, 'two' => 2, 'three' => 3 }
      #
      #   # good
      #   { one: 1, two: 2, three: 3 }
      class StringHashKeys < Cop
        MSG = 'Prefer symbols instead of strings as hash keys.'.freeze

        def_node_matcher :string_hash_key?, <<-PATTERN
          (pair (str _) _)
        PATTERN

        def on_pair(node)
          return unless string_hash_key?(node)
          add_offense(node.key)
        end

        def autocorrect(node)
          lambda do |corrector|
            symbol_content = node.str_content.to_sym.inspect
            corrector.replace(node.source_range, symbol_content)
          end
        end
      end
    end
  end
end
