# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use a consistent style for named format string tokens.
      #
      # **Note:**
      # `unannotated` style cop only works for strings
      # which are passed as arguments to those methods:
      # `sprintf`, `format`, `%`.
      # The reason is that *unannotated* format is very similar
      # to encoded URLs or Date/Time formatting strings.
      #
      # @example EnforcedStyle: annotated (default)
      #
      #   # bad
      #   format('%{greeting}', greeting: 'Hello')
      #   format('%s', 'Hello')
      #
      #   # good
      #   format('%<greeting>s', greeting: 'Hello')
      #
      # @example EnforcedStyle: template
      #
      #   # bad
      #   format('%<greeting>s', greeting: 'Hello')
      #   format('%s', 'Hello')
      #
      #   # good
      #   format('%{greeting}', greeting: 'Hello')
      #
      # @example EnforcedStyle: unannotated
      #
      #   # bad
      #   format('%<greeting>s', greeting: 'Hello')
      #   format('%{greeting}', 'Hello')
      #
      #   # good
      #   format('%s', 'Hello')
      class FormatStringToken < Cop
        include ConfigurableEnforcedStyle

        FIELD_CHARACTERS = Regexp.union(%w[A B E G X a b c d e f g i o p s u x])
        FORMAT_STRING_METHODS = %i[sprintf format %].freeze

        STYLE_PATTERNS = {
          annotated: /(?<token>%<[^>]+>#{FIELD_CHARACTERS})/,
          template: /(?<token>%\{[^\}]+\})/,
          unannotated: /(?<token>%#{FIELD_CHARACTERS})/
        }.freeze

        def on_str(node)
          return if placeholder_argument?(node)
          return if node.each_ancestor(:xstr, :regexp).any?

          tokens(node) do |detected_style, token_range|
            if detected_style == style ||
               unannotated_format?(node, detected_style)
              correct_style_detected
            else
              style_detected(detected_style)
              add_offense(node, location: token_range,
                                message: message(detected_style))
            end
          end
        end

        private

        def includes_format_methods?(node)
          node.each_ancestor.any? do |ancestor|
            FORMAT_STRING_METHODS.include?(ancestor.method_name)
          end
        end

        def unannotated_format?(node, detected_style)
          detected_style == :unannotated && !includes_format_methods?(node)
        end

        def message(detected_style)
          "Prefer #{message_text(style)} over #{message_text(detected_style)}."
        end

        # rubocop:disable Style/FormatStringToken
        def message_text(style)
          case style
          when :annotated then 'annotated tokens (like `%<foo>s`)'
          when :template then 'template tokens (like `%{foo}`)'
          when :unannotated then 'unannotated tokens (like `%s`)'
          end
        end
        # rubocop:enable Style/FormatStringToken

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

        def placeholder_argument?(node)
          return false unless node.parent
          return true if node.parent.pair_type?

          placeholder_argument?(node.parent)
        end
      end
    end
  end
end
