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

        def on_hash(node)
          return if node.pairs.empty? || node.pairs.any?(&:hash_rocket?)
          return unless (parent = node.parent)
          return unless parent.kwsplat_type?

          add_offense(parent) do |corrector|
            corrector.remove(parent.loc.operator)
            corrector.remove(opening_brace(node))
            corrector.remove(closing_brace(node))
          end
        end

        private

        def opening_brace(node)
          node.loc.begin.join(node.children.first.source_range.begin)
        end

        def closing_brace(node)
          node.children.last.source_range.end.join(node.loc.end)
        end
      end
    end
  end
end
