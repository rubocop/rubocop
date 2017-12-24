# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in hash literals.
      #
      # @example EnforcedStyleForMultiline: consistent_comma
      #   # bad
      #   a = { foo: 1, bar: 2, }
      #
      #   # good
      #   a = {
      #     foo: 1, bar: 2,
      #     qux: 3,
      #   }
      #
      #   # good
      #   a = {
      #     foo: 1,
      #     bar: 2,
      #   }
      #
      # @example EnforcedStyleForMultiline: comma
      #   # bad
      #   a = { foo: 1, bar: 2, }
      #
      #   # good
      #   a = {
      #     foo: 1,
      #     bar: 2,
      #   }
      #
      # @example EnforcedStyleForMultiline: no_comma (default)
      #   # bad
      #   a = { foo: 1, bar: 2, }
      #
      #   # good
      #   a = {
      #     foo: 1,
      #     bar: 2
      #   }
      class TrailingCommaInHashLiteral < Cop
        include TrailingComma

        def on_hash(node)
          check_literal(node, 'item of %<article>s hash')
        end

        def autocorrect(range)
          PunctuationCorrector.swap_comma(range)
        end
      end
    end
  end
end
