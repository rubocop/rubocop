# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant uses of double splat hash braces.
      #
      # @example
      #
      #   # bad
      #   do_something(**{foo: bar, baz: qux})
      #
      #   # good
      #   do_something(foo: bar, baz: qux)
      #
      class RedundantDoubleSplatHashBraces < Base
        extend AutoCorrector

        MSG = 'Remove the redundant double splat and braces, use keyword arguments directly.'

        # @!method double_splat_hash_braces?(node)
        def_node_matcher :double_splat_hash_braces?, <<~PATTERN
          (hash (kwsplat (hash ...)))
        PATTERN

        def on_hash(node)
          return if node.pairs.empty? || node.pairs.any?(&:hash_rocket?)

          grandparent = node.parent&.parent
          return unless double_splat_hash_braces?(grandparent)

          add_offense(grandparent) do |corrector|
            corrector.replace(grandparent, node.pairs.map(&:source).join(', '))
          end
        end
      end
    end
  end
end
