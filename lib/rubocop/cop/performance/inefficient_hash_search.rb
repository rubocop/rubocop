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
        def_node_matcher :inefficient_include?, <<-PATTERN
          (send $(send _ ${:keys :values}) :include? $_)
        PATTERN

        def on_send(node)
          add_offense(node, message: msg(node)) if inefficient_include?(node)
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

        def msg(node)
          "Use `##{autocorrect_method(node)}` instead of "\
            "`##{current_method(node)}.include?`."
        end

        def autocorrect_method(node)
          case current_method(node)
          when :keys then use_long_method ? 'has_key?' : 'key?'
          when :values then use_long_method ? 'has_value?' : 'value?'
          end
        end

        def current_method(node)
          node.children[0].method_name
        end

        def use_long_method
          preferred_config = config.for_all_cops['Style/PreferredHashMethods']
          preferred_config &&
            preferred_config['EnforcedStyle'] == 'long' &&
            preferred_config['Enabled']
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
