# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant line continuation.
      #
      # A line continuation is redundant when removing the backslash does not
      # change how the program parses: the source is reparsed without the
      # backslash and the resulting AST is compared to the original. Only
      # backslashes that are pure noise are reported; backslashes that are
      # significant — inside strings, for string concatenation, before an
      # operator or argument that would otherwise start a new statement, and
      # so on — are left alone, as are backslashes in comments.
      #
      # @example
      #   # bad
      #   foo. \
      #     bar
      #   foo \
      #     &.bar \
      #       .baz
      #
      #   # good
      #   foo.
      #     bar
      #   foo
      #     &.bar
      #       .baz
      #
      #   # bad
      #   [foo, \
      #     bar]
      #   {foo: \
      #     bar}
      #
      #   # good
      #   [foo,
      #     bar]
      #   {foo:
      #     bar}
      #
      #   # bad
      #   foo(bar, \
      #     baz)
      #
      #   # good
      #   foo(bar,
      #     baz)
      #
      #   # also good - backslash in string concatenation is not redundant
      #   foo('bar' \
      #     'baz')
      #
      #   # also good - backslash at the end of a comment is not redundant
      #   foo(bar, # \
      #     baz)
      #
      #   # also good - backslash at the line following the newline begins with a + or -,
      #   # it is not redundant
      #   1 \
      #     + 2 \
      #       - 3
      #
      #   # also good - backslash with newline between the method name and its arguments,
      #   # it is not redundant.
      #   some_method \
      #     (argument)
      #
      class RedundantLineContinuation < Base
        include MatchRange
        include ReparsedEquivalence
        extend AutoCorrector

        MSG = 'Redundant line continuation.'
        LINE_CONTINUATION = '\\'
        LINE_CONTINUATION_PATTERN = /(\\\n)/.freeze
        STRING_TOKEN_TYPES = %i[tSTRING tSTRING_CONTENT].freeze

        def on_new_investigation
          return unless processed_source.ast

          # A backslash is redundant if the source parses to the same AST
          # without it; verification is the offense logic itself, so oversized
          # scopes are reparsed regardless of size.
          verified_by_reparse(line_continuation_candidates, oversized: :verify).each do |range|
            add_offense(range) do |corrector|
              corrector.remove_leading(range, 1)
            end
          end

          inspect_end_of_ruby_code_line_continuation
        end

        private

        def apply_reparse_correction(corrector, range)
          corrector.remove_leading(range, 1)
        end

        def line_continuation_candidates
          candidates = []

          each_match_range(processed_source.ast.source_range, LINE_CONTINUATION_PATTERN) do |range|
            next if within_comment?(range) || within_string_content?(range)
            next if leading_dot_method_chain_with_blank_line?(range)

            candidates << range
          end

          candidates
        end

        def within_comment?(range)
          processed_source.comments.any? do |comment|
            comment.source_range.overlaps?(range)
          end
        end

        # A backslash in string content is never a redundant line continuation
        # (removing it changes the string's value, which the reparse check would
        # detect); skipping it up front just avoids a useless reparse.
        def within_string_content?(range)
          @string_content_ranges ||= processed_source.tokens.filter_map do |token|
            token.pos if STRING_TOKEN_TYPES.include?(token.type)
          end

          @string_content_ranges.any? { |pos| pos.overlaps?(range) }
        end

        # The `parser` gem, unlike Ruby itself, accepts a leading-dot method
        # chain continued across a blank line, so the reparse check alone would
        # deem the backslash redundant even though removing it breaks the code
        # on MRI. Prism matches Ruby here and does not need this guard.
        def leading_dot_method_chain_with_blank_line?(range)
          return false unless range.source_line.strip.start_with?('.', '&.')

          processed_source[range.line].strip.empty?
        end

        def inspect_end_of_ruby_code_line_continuation
          last_line_number = processed_source.ast.last_line
          last_line = processed_source.lines[last_line_number - 1]
          return unless last_line&.end_with?(LINE_CONTINUATION)

          range = trailing_line_continuation_range(last_line_number)
          return if within_comment?(range)
          return if verified_by_reparse([range], oversized: :verify).empty?

          add_offense(range) do |corrector|
            corrector.remove_trailing(range, 1)
          end
        end

        # The backslash is the last character of the line; locate it by the line's
        # position in the buffer rather than treating the column as an absolute offset
        # (which corrupts an earlier line in multi-line files).
        def trailing_line_continuation_range(line_number)
          line_range = processed_source.buffer.line_range(line_number)
          range_between(line_range.end_pos - 1, line_range.end_pos)
        end
      end
    end
  end
end
