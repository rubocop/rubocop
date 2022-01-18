# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for hash literals for which the values need not be specified explicitly.
      #
      # @example
      #   # bad
      #   { foo: foo, bar: bar}
      #
      #   # good
      #   { foo:, bar: }
      #
      class HashValues < Base
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 3.1

        MSG = 'Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.'

        def on_pair(node)
          return if node.value_omission?

          key_node = node.key
          value_node = node.value

          return unless key_node.value == value_node.method_name

          add_offense(node) do |corrector|
            corrector.replace(node, "#{key_node.value}:")
          end
        end
      end
    end
  end
end
