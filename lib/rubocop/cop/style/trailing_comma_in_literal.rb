# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in array and hash literals.
      #
      # @example EnforcedStyleForMultiline: consistent_comma
      #   # bad
      #   a = [1, 2,]
      #
      #   # good
      #   a = [
      #     1, 2,
      #     3,
      #   ]
      #
      #   # good
      #   a = [
      #     1,
      #     2,
      #   ]
      #
      # @example EnforcedStyleForMultiline: comma
      #   # bad
      #   a = [1, 2,]
      #
      #   # good
      #   a = [
      #     1,
      #     2,
      #   ]
      #
      # @example EnforcedStyleForMultiline: no_comma (default)
      #   # bad
      #   a = [1, 2,]
      #
      #   # good
      #   a = [
      #     1,
      #     2
      #   ]
      class TrailingCommaInLiteral < Cop
        include ArraySyntax
        include TrailingComma

        def on_array(node)
          check_literal(node, 'item of %s array') if node.square_brackets?
        end

        def on_hash(node)
          check_literal(node, 'item of %s hash')
        end

        private

        def check_literal(node, kind)
          return if node.children.empty?
          # A braceless hash is the last parameter of a method call and will be
          # checked as such.
          return unless brackets?(node)

          check(node, node.children, kind,
                node.children.last.source_range.end_pos,
                node.loc.end.begin_pos)
        end
      end
    end
  end
end
