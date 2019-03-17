# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing comma in argument lists.
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

        private

        def avoid_autocorrect?(args)
          args.last.hash_type? && args.last.braces? &&
            braces_will_be_removed?(args)
        end

        # Returns true if running with --auto-correct would remove the braces
        # of the last argument.
        def braces_will_be_removed?(args)
          brace_config = config.for_cop('Style/BracesAroundHashParameters')
          return false unless brace_config.fetch('Enabled')
          return false if brace_config['AutoCorrect'] == false

          brace_style = brace_config['EnforcedStyle']
          return true if brace_style == 'no_braces'

          return false unless brace_style == 'context_dependent'

          args.one? || !args[-2].hash_type?
        end
      end
    end
  end
end
