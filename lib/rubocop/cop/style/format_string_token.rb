# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use a consistent style for named format string tokens.
      #
      # NOTE: `unannotated` style cop only works for strings
      # which are passed as arguments to those methods:
      # `printf`, `sprintf`, `format`, `%`.
      # The reason is that _unannotated_ format is very similar
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

        def on_str(node)
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

        def_node_matcher :format_string_in_typical_context?, <<~PATTERN
          {
            ^(send _ {:format :sprintf :printf} %0 ...)
            ^(send %0 :% _)
          }
        PATTERN

        def unannotated_format?(node, detected_style)
          detected_style == :unannotated &&
            !format_string_in_typical_context?(node)
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
            source_map.expression.adjust(begin_pos: +1, end_pos: -1)
          else
            source_map.expression
          end
        end

        def token_ranges(contents)
          format_string = RuboCop::Cop::Utils::FormatString.new(contents.source)

          format_string.format_sequences.each do |seq|
            next if seq.percent?

            detected_style = seq.style
            token = contents.begin.adjust(
              begin_pos: seq.begin_pos,
              end_pos:   seq.end_pos
            )

            yield(detected_style, token)
          end
        end
      end
    end
  end
end
