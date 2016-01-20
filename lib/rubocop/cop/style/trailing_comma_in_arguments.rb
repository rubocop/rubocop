# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in argument lists.
      #
      # @example
      #   # always bad
      #   method(1, 2,)
      #
      #   # good if EnforcedStyleForMultiline is consistent_comma
      #   method(
      #     1, 2,
      #     3,
      #   )
      #
      #   # good if EnforcedStyleForMultiline is comma or consistent_comma
      #   method(
      #     1,
      #     2,
      #   )
      #
      #   # good if EnforcedStyleForMultiline is no_comma
      #   method(
      #     1,
      #     2
      #   )
      class TrailingCommaInArguments < Cop
        include TrailingComma

        def on_send(node)
          _receiver, _method_name, *args = *node
          return if args.empty?
          # It's impossible for a method call without parentheses to have
          # a trailing comma.
          return unless brackets?(node)

          check(node, args, 'parameter of %s method call',
                args.last.source_range.end_pos, node.source_range.end_pos)
        end
      end
    end
  end
end
