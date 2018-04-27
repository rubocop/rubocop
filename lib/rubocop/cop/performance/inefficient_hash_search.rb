# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop checks for inefficient searching of keys and values within
      # hashes.
      #
      # `Hash#keys.include?` is less efficient than `Hash#key?` because
      # the former allocates a new array and then performs an O(n) search
      # through that array, while `Hash#key?` does not allocate any array and
      # performs a faster O(1) search for the key.
      #
      # `Hash#values.include?` is less efficient than `Hash#value?`. While they
      # both perform an O(n) search through all of the values, calling `values`
      # allocates a new array while using `value?` does not.
      #
      # @example
      #   # bad
      #   { a: 1, b: 2 }.keys.include?(:a)
      #   { a: 1, b: 2 }.keys.include?(:z)
      #   h = { a: 1, b: 2 }; h.keys.include?(100)
      #
      #   # good
      #   { a: 1, b: 2 }.key?(:a)
      #   { a: 1, b: 2 }.has_key?(:z)
      #   h = { a: 1, b: 2 }; h.key?(100)
      #
      #   # bad
      #   { a: 1, b: 2 }.values.include?(2)
      #   { a: 1, b: 2 }.values.include?('garbage')
      #   h = { a: 1, b: 2 }; h.values.include?(nil)
      #
      #   # good
      #   { a: 1, b: 2 }.value?(2)
      #   { a: 1, b: 2 }.has_value?('garbage')
      #   h = { a: 1, b: 2 }; h.value?(nil)
      #
      class InefficientHashSearch < Cop
        KEYS_MSG = 'Use `#key?` instead of `#keys.include?`.'.freeze
        VALUES_MSG = 'Use `#value?` instead of `#values.include?`.'.freeze

        def_node_matcher :keys_include?, <<-PATTERN
          (send (send _ :keys) :include? _)
        PATTERN

        def_node_matcher :values_include?, <<-PATTERN
          (send (send _ :values) :include? _)
        PATTERN

        def on_send(node)
          add_offense(node, message: KEYS_MSG) if keys_include?(node)
          add_offense(node, message: VALUES_MSG) if values_include?(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            # Replace `keys.include?` or `values.include?` with the appropriate
            # `key?`/`value?` method.
            corrector.replace(
              node.loc.expression,
              "#{autocorrect_hash_expression(node)}."\
              "#{autocorrect_method(node)}(#{autocorrect_argument(node)})"
            )
          end
        end

        private

        def autocorrect_method(node)
          old_method = node.children[0].loc.selector.source
          old_method == 'keys' ? 'key?' : 'value?'
        end

        def autocorrect_argument(node)
          node.arguments.first.source
        end

        def autocorrect_hash_expression(node)
          node.children[0].children[0].loc.expression.source
        end
      end
    end
  end
end
