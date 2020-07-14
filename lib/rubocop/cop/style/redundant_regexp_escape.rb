# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant escapes inside Regexp literals.
      #
      # @example
      #   # bad
      #   %r{foo\/bar}
      #
      #   # good
      #   %r{foo/bar}
      #
      #   # good
      #   /foo\/bar/
      #
      #   # good
      #   %r/foo\/bar/
      #
      #   # good
      #   %r!foo\!bar!
      #
      #   # bad
      #   /a\-b/
      #
      #   # good
      #   /a-b/
      #
      #   # bad
      #   /[\+\-]\d/
      #
      #   # good
      #   /[+\-]\d/
      class RedundantRegexpEscape < Cop
        include RangeHelp
        include RegexpLiteralHelp

        MSG_REDUNDANT_ESCAPE = 'Redundant escape inside regexp literal'

        ALLOWED_ALWAYS_ESCAPES = ' []^\\#'.chars.freeze
        ALLOWED_WITHIN_CHAR_CLASS_METACHAR_ESCAPES = '-'.chars.freeze
        ALLOWED_OUTSIDE_CHAR_CLASS_METACHAR_ESCAPES = '.*+?{}()|$'.chars.freeze

        def on_regexp(node)
          each_escape(node) do |char, index, within_character_class|
            next if allowed_escape?(node, char, within_character_class)

            add_offense(
              node,
              location: escape_range_at_index(node, index),
              message: MSG_REDUNDANT_ESCAPE
            )
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            each_escape(node) do |char, index, within_character_class|
              next if allowed_escape?(node, char, within_character_class)

              corrector.remove_leading(escape_range_at_index(node, index), 1)
            end
          end
        end

        private

        def allowed_escape?(node, char, within_character_class)
          # Strictly speaking a few single-letter metachars are currently
          # unnecessary to "escape", e.g. g, i, E, F, but enumerating them is
          # rather difficult, and their behaviour could change over time with
          # different versions of Ruby so that e.g. /\g/ != /g/
          return true if /[[:alnum:]]/.match?(char)
          return true if ALLOWED_ALWAYS_ESCAPES.include?(char) || delimiter?(node, char)

          if within_character_class
            ALLOWED_WITHIN_CHAR_CLASS_METACHAR_ESCAPES.include?(char)
          else
            ALLOWED_OUTSIDE_CHAR_CLASS_METACHAR_ESCAPES.include?(char)
          end
        end

        def delimiter?(node, char)
          delimiters = [
            node.loc.begin.source[-1],
            node.loc.end.source[0]
          ]

          delimiters.include?(char)
        end

        def each_escape(node)
          pattern_source(node).each_char.with_index.reduce(
            [nil, 0]
          ) do |(previous, char_class_depth), (current, index)|
            if previous == '\\'
              yield [current, index - 1, !char_class_depth.zero?]

              [nil, char_class_depth]
            elsif previous == '['
              [current, char_class_depth + 1]
            elsif current == ']'
              [current, char_class_depth - 1]
            else
              [current, char_class_depth]
            end
          end
        end

        def escape_range_at_index(node, index)
          regexp_begin = node.loc.begin.end_pos

          start = regexp_begin + index

          range_between(start, start + 2)
        end
      end
    end
  end
end
