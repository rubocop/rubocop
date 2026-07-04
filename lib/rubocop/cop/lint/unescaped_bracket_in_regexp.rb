# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for Regexps (both literals and via `Regexp.new` / `Regexp.compile`)
      # that contain unescaped `]` characters.
      #
      # It emulates the following Ruby warning:
      #
      # [source,ruby]
      # ----
      # $ ruby -e '/abc]123/'
      # -e:1: warning: regular expression has ']' without escape: /abc]123/
      # ----
      #
      # @example
      #   # bad
      #   /abc]123/
      #   %r{abc]123}
      #   Regexp.new('abc]123')
      #   Regexp.compile('abc]123')
      #
      #   # good
      #   /abc\]123/
      #   %r{abc\]123}
      #   Regexp.new('abc\]123')
      #   Regexp.compile('abc\]123')
      #
      class UnescapedBracketInRegexp < Base
        extend AutoCorrector

        MSG = 'Regular expression has `]` without escape.'
        RESTRICT_ON_SEND = %i[new compile].freeze

        # @!method regexp_constructor(node)
        def_node_search :regexp_constructor, <<~PATTERN
          (send
            (const {nil? cbase} :Regexp) {:new :compile}
            $str
            ...
          )
        PATTERN

        def on_regexp(node)
          RuboCop::Util.silence_warnings do
            detect_offenses_in_tree(node, node.parsed_tree)
          end
        end

        def on_send(node)
          # Ignore nodes that contain interpolation
          return if node.each_descendant(:dstr).any?

          regexp_constructor(node) do |text|
            detect_offenses_in_tree(text, parse_regexp(text.value))
          end
        end

        private

        # When a character class opens with a bare `]` (e.g. `[^]]`), `regexp_parser` parses
        # `[^]` / `[]` as an empty set and reports the closing `]` as a separate literal.
        # Ruby treats that `]` as the end of the class, not as an unescaped bracket,
        # so the first `]` following an empty set must be skipped.
        def detect_offenses_in_tree(node, tree)
          return unless tree

          skip_class_closer = false
          tree.each_expression do |expr|
            if empty_character_set?(expr)
              skip_class_closer = true
            elsif expr.type?(:literal)
              skip_class_closer = detect_offenses(node, expr, skip_class_closer)
            end
          end
        end

        def empty_character_set?(expr)
          expr.type?(:set) && expr.expressions.empty?
        end

        def detect_offenses(node, expr, skip_class_closer)
          expr.text.scan(/(?<!\\)\]/) do
            pos = Regexp.last_match.begin(0)

            # The first `]` following an empty `[^]` / `[]` set closes the character class.
            if skip_class_closer
              skip_class_closer = false
              next
            end

            # If the unescaped bracket is the first character of the regexp, Ruby does not warn.
            # `pos` is relative to the sub-expression, so add its start offset (`expr.ts`).
            next if (expr.ts + pos).zero?

            location = range_at_index(node, expr.ts, pos)

            add_offense(location) do |corrector|
              corrector.replace(location, '\]')
            end
          end

          skip_class_closer
        end

        def range_at_index(node, index, offset)
          adjustment = index + offset
          node.loc.begin.end.adjust(begin_pos: adjustment, end_pos: adjustment + 1)
        end
      end
    end
  end
end
