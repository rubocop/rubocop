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
          return unless node.arguments? && node.parenthesized?

          check(node, node.arguments, 'parameter of %s method call',
                node.last_argument.source_range.end_pos,
                node.source_range.end_pos)
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
          return false unless brace_config['Enabled']
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
