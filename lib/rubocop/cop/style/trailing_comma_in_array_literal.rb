# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in array literals.
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
      class TrailingCommaInArrayLiteral < Cop
        include TrailingComma

        def autocorrect(range)
          PunctuationCorrector.swap_comma(range)
        end

        def on_array(node)
          return unless node.square_brackets?

          check_literal(node, 'item of %<article>s array')
        end
      end
    end
  end
end
