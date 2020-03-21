# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in argument lists.
      # The supported styles are:
      #
      # - `consistent_comma`: Requires a comma after the last argument,
      # for all parenthesized method calls with arguments.
      # - `comma`: Requires a comma after the last argument, but only for
      # parenthesized method calls where each argument is on its own line.
      # - `no_comma`: Does not requires a comma after the last argument.
      #
      # @example EnforcedStyleForMultiline: consistent_comma
      #   # bad
      #   method(1, 2,)
      #
      #   # good
      #   method(1, 2)
      #
      #   # good
      #   method(
      #     1, 2,
      #     3,
      #   )
      #
      #   # good
      #   method(
      #     1, 2, 3,
      #   )
      #
      #   # good
      #   method(
      #     1,
      #     2,
      #   )
      #
      # @example EnforcedStyleForMultiline: comma
      #   # bad
      #   method(1, 2,)
      #
      #   # good
      #   method(1, 2)
      #
      #   # bad
      #   method(
      #     1, 2,
      #     3,
      #   )
      #
      #   # good
      #   method(
      #     1, 2,
      #     3
      #   )
      #
      #   # bad
      #   method(
      #     1, 2, 3,
      #   )
      #
      #   # good
      #   method(
      #     1, 2, 3
      #   )
      #
      #   # good
      #   method(
      #     1,
      #     2,
      #   )
      #
      # @example EnforcedStyleForMultiline: no_comma (default)
      #   # bad
      #   method(1, 2,)
      #
      #   # good
      #   method(1, 2)
      #
      #   # good
      #   method(
      #     1,
      #     2
      #   )
      class TrailingCommaInArguments < Cop
        include TrailingComma

        def on_send(node)
          return unless node.arguments? && node.parenthesized?

          check(node, node.arguments, 'parameter of %<article>s method call',
                node.last_argument.source_range.end_pos,
                node.source_range.end_pos)
        end
        alias on_csend on_send

        def autocorrect(range)
          PunctuationCorrector.swap_comma(range)
        end

        def self.autocorrect_incompatible_with
          [Layout::HeredocArgumentClosingParenthesis]
        end
      end
    end
  end
end
