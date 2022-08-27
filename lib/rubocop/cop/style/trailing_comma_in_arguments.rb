# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for trailing comma in argument lists.
      # The supported styles are:
      #
      # * `consistent_comma`: Requires a comma after the last argument,
      # for all parenthesized method calls with arguments.
      # * `comma`: Requires a comma after the last argument, but only for
      # parenthesized method calls where each argument is on its own line.
      # * `no_comma`: Requires that there is no comma after the last
      # argument.
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
      class TrailingCommaInArguments < Base
        include TrailingComma
        extend AutoCorrector

        def on_send(node)
          return unless node.arguments? && node.parenthesized?

          check(node, node.arguments, 'parameter of %<article>s method call',
                node.last_argument.source_range.end_pos,
                node.source_range.end_pos)
        end
        alias on_csend on_send

        def self.autocorrect_incompatible_with
          [Layout::HeredocArgumentClosingParenthesis]
        end
      end
    end
  end
end
