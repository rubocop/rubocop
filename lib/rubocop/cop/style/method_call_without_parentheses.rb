# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unwanted parentheses method calls with parameters.
      #
      # @example
      #   # bad
      #   array.delete(e)
      #
      #   # good
      #   array.delete e
      #
      #   # bad
      #   foo.enforce(strict: true)
      #
      #   # good
      #   foo.enforce strict: true
      #
      # @example AllowParenthesesInMultilineCall: false (default)
      #   # bad
      #   foo.enforce(
      #     strict: true
      #   )
      #
      #   # good
      #   foo.enforce \
      #     strict: true
      #
      # @example AllowParenthesesInMultilineCall: true
      #   # good
      #   foo.enforce(
      #     strict: true
      #   )
      #
      #   # good
      #   foo.enforce \
      #     strict: true
      #
      # @example AllowParenthesesInChaining: false (default)
      #   # bad
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      #
      # @example AllowParenthesesInChaining: true
      #   # good
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      class MethodCallWithoutParentheses < Cop
        MSG = 'Do not use parentheses for method calls.'.freeze

        TRAILING_WHITESPACE_REGEX = /\s+\Z/.freeze

        def on_send(node)
          return unless node.parenthesized?
          return if special_case_for_parentheses?(node)

          add_offense(node, location: node.loc.begin.join(node.loc.end))
        end

        def autocorrect(node)
          lambda do |corrector|
            if parentheses_at_end_of_multiline?(node)
              corrector.replace(node.loc.begin, ' \\')
            else
              corrector.replace(node.loc.begin, ' ')
            end
            corrector.remove(node.loc.end)
          end
        end

        private

        def special_case_for_parentheses?(node)
          node.implicit_call? ||
            allow_multiline_call_with_parentheses?(node) ||
            chained_call?(node) ||
            nested_call?(node)
        end

        def allow_multiline_call_with_parentheses?(node)
          cop_config.fetch('AllowParenthesesInMultilineCall', false) &&
            node.multiline?
        end

        def chained_call?(node)
          cop_config.fetch('AllowParenthesesInChaining', false) &&
            node.descendants.first && node.descendants.first.send_type?
        end

        def nested_call?(node)
          node.parent &&
            (node.parent.send_type? ||
             node.parent.pair_type? ||
             node.parent.array_type?)
        end

        def parentheses_at_end_of_multiline?(node)
          node.multiline? &&
            node.loc.begin.source_line
                .gsub(TRAILING_WHITESPACE_REGEX, '')
                .end_with?('(')
        end
      end
    end
  end
end
