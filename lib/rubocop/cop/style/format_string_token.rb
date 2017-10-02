# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use a consistent style for named format string tokens.
      #
      # @example
      #
      #   EnforcedStyle: annotated
      #
      #   # bad
      #
      #   format('%{greeting}', greeting: 'Hello')
      #   format('%s', 'Hello')
      #
      #   # good
      #
      #   format('%<greeting>s', greeting: 'Hello')
      #
      # @example
      #
      #   EnforcedStyle: template
      #
      #   # bad
      #
      #   format('%<greeting>s', greeting: 'Hello')
      #   format('%s', 'Hello')
      #
      #   # good
      #
      #   format('%{greeting}', greeting: 'Hello')
      class FormatStringToken < Cop
        include ConfigurableEnforcedStyle

        FIELD_CHARACTERS = Regexp.union(%w[A B E G X a b c d e f g i o p s u x])

        STYLE_PATTERNS = {
          annotated: /(?<token>%<[^>]+>#{FIELD_CHARACTERS})/,
          template:  /(?<token>%\{[^\}]+\})/
        }.freeze

        TOKEN_PATTERN = Regexp.union(STYLE_PATTERNS.values)

        def on_str(node)
          return if node.each_ancestor(:xstr).any?

          tokens(node) do |detected_style, token_range|
            if detected_style == style
              correct_style_detected
            else
              style_detected(detected_style)
              add_offense(node, location: token_range,
                                message: message(detected_style))
            end
          end
        end

        private

        def message(detected_style)
          "Prefer #{message_text(style)} over #{message_text(detected_style)}."
        end

        # rubocop:disable FormatStringToken
        def message_text(style)
          case style
          when :annotated then 'annotated tokens (like `%<foo>s`)'
          when :template  then 'template tokens (like `%{foo}`)'
          end
        end
        # rubocop:enable FormatStringToken

        def tokens(str_node, &block)
          return if str_node.source == '__FILE__'

          token_ranges(str_contents(str_node.loc), &block)
        end

        def str_contents(source_map)
          if source_map.is_a?(Parser::Source::Map::Heredoc)
            source_map.heredoc_body
          elsif source_map.begin
            slice_source(
              source_map.expression,
              source_map.expression.begin_pos + 1,
              source_map.expression.end_pos - 1
            )
          else
            source_map.expression
          end
        end

        def token_ranges(contents)
          while (offending_match = match_token(contents))
            detected_style, *range = *offending_match
            token, contents = split_token(contents, *range)
            yield(detected_style, token)
          end
        end

        def match_token(source_range)
          supported_styles.each do |style_name|
            pattern = STYLE_PATTERNS.fetch(style_name)
            match = source_range.source.match(pattern)
            next unless match

            return [style_name, match.begin(:token), match.end(:token)]
          end

          nil
        end

        def split_token(source_range, match_begin, match_end)
          token =
            slice_source(
              source_range,
              source_range.begin_pos + match_begin,
              source_range.begin_pos + match_end
            )

          remainder =
            slice_source(
              source_range,
              source_range.begin_pos + match_end,
              source_range.end_pos
            )

          [token, remainder]
        end

        def slice_source(source_range, new_begin, new_end)
          Parser::Source::Range.new(
            source_range.source_buffer,
            new_begin,
            new_end
          )
        end
      end
    end
  end
end
