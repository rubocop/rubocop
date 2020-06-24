# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unnecessary single-element Regexp character classes.
      #
      # @example
      #
      #   # bad
      #   r = /[x]/
      #
      #   # good
      #   r = /x/
      #
      #   # bad
      #   r = /[\s]/
      #
      #   # good
      #   r = /\s/
      #
      #   # good
      #   r = /[ab]/
      class RedundantRegexpCharacterClass < Cop
        include MatchRange
        include RegexpLiteralHelp

        MSG_REDUNDANT_CHARACTER_CLASS = 'Redundant single-element character class, ' \
        '`%<char_class>s` can be replaced with `%<element>s`.'

        PATTERN = /
          (
            (?<!\\)           # No \-prefix (i.e. not escaped)
            \[                # Literal [
            (?!\#\{)          # Not (the start of) an interpolation
            (?:               # Either...
             \\[^b] |         # Any escaped character except b (which would change behaviour)
             [^.*+?{}()|$] |  # or one that doesn't require escaping outside the character class
             \\[upP]\{[^}]+\} # or a unicode code-point or property
            )
            (?<!\\)           # No \-prefix (i.e. not escaped)
            \]                # Literal ]
          )
        /x.freeze

        def on_regexp(node)
          each_redundant_character_class(node) do |loc|
            next if whitespace_in_free_space_mode?(node, loc)

            add_offense(
              node,
              location: loc,
              message: format(
                MSG_REDUNDANT_CHARACTER_CLASS,
                char_class: loc.source,
                element: without_character_class(loc)
              )
            )
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            each_redundant_character_class(node) do |loc|
              corrector.replace(loc, without_character_class(loc))
            end
          end
        end

        def each_redundant_character_class(node)
          pattern_source(node).scan(PATTERN) do
            yield match_range(node.loc.begin.end, Regexp.last_match)
          end
        end

        private

        def without_character_class(loc)
          loc.source[1..-2]
        end

        def whitespace_in_free_space_mode?(node, loc)
          return false unless freespace_mode_regexp?(node)

          /\[\s\]/.match?(loc.source)
        end
      end
    end
  end
end
