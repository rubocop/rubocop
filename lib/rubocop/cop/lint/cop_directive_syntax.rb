# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective
# rubocop:disable Style/DoubleCopDisableDirective
module RuboCop
  module Cop
    module Lint
      # Checks that `# rubocop:enable ...` and `# rubocop:disable ...` statements
      # are strictly formatted.
      #
      # A comment can be added to the directive by prefixing it with `--`.
      #
      # @example
      #   # bad
      #   # rubocop:disable Layout/LineLength Style/Encoding
      #
      #   # good
      #   # rubocop:disable Layout/LineLength, Style/Encoding
      #
      #   # bad
      #   # rubocop:disable
      #
      #   # good
      #   # rubocop:disable all
      #
      #   # bad
      #   # rubocop:disable Layout/LineLength # rubocop:disable Style/Encoding
      #
      #   # good
      #   # rubocop:disable Layout/LineLength
      #   # rubocop:disable Style/Encoding
      #
      #   # bad
      #   # rubocop:wrongmode Layout/LineLength
      #
      #   # good
      #   # rubocop:disable Layout/LineLength
      #
      #   # bad
      #   # rubocop:disable Layout/LineLength comment
      #
      #   # good
      #   # rubocop:disable Layout/LineLength -- comment
      #
      #   # bad
      #   # rucocop:disable Layout/LineLength
      #
      #   # good
      #   # rubocop:disable Layout/LineLength
      #
      #   # bad
      #   # rubocop:disable Layout/LineLenght
      #
      #   # good
      #   # rubocop:disable Layout/LineLength
      #
      class CopDirectiveSyntax < Base
        COMMON_MSG = 'Malformed directive comment detected.'

        MISSING_MODE_NAME_MSG = 'The mode name is missing.'
        INVALID_MODE_NAME_MSG = 'The mode name must be one of `enable`, `disable`, `disable-next`, `todo`, `todo-next`, `push`, or `pop`.' # rubocop:disable Layout/LineLength
        MISSING_COP_NAME_MSG = 'The cop name is missing.'
        MALFORMED_COP_NAMES_MSG = 'Cop names must be separated by commas. ' \
                                  'Comment in the directive must start with `--`.'
        NEXT_DIRECTIVE_AT_EOL_MSG = 'A `-next` directive must be on its own line, above the ' \
                                    'statement it applies to.'
        INVALID_KEYWORD_MSG = 'The directive keyword must be `rubocop`, not `%<keyword>s`.'
        UNKNOWN_COP_MSG = 'Unknown cop name `%<name>s`%<suggestion>s.'

        # A comment that looks like an attempted directive: any keyword
        # followed by a colon and a valid mode name.
        NEAR_MISS_KEYWORD_REGEXP = /
          \A\#+\s*(?<keyword>[A-Za-z][\w-]*)\s*:\s*
          (?:#{DirectiveComment::MODES_PATTERN})\b
        /x.freeze

        def on_new_investigation
          processed_source.comments.each do |comment|
            directive_comment = DirectiveComment.new(comment)
            if directive_comment.start_with_marker?
              check_directive(comment, directive_comment)
            elsif (keyword = near_miss_keyword(comment))
              message = format("#{COMMON_MSG} #{INVALID_KEYWORD_MSG}", keyword: keyword)
              add_offense(comment, message: message)
            end
          end
        end

        private

        def check_directive(comment, directive_comment)
          if directive_comment.malformed?
            add_offense(comment, message: offense_message(directive_comment))
          elsif misplaced_next_directive?(directive_comment)
            add_offense(comment, message: NEXT_DIRECTIVE_AT_EOL_MSG)
          elsif (name = unknown_cop_name(directive_comment))
            add_offense(comment, message: unknown_cop_message(directive_comment, name))
          end
        end

        # An EOL `disable-next` is not honored - it must fail loudly instead
        # of silently doing nothing.
        def misplaced_next_directive?(directive_comment)
          directive_comment.disable_next? &&
            !processed_source.comment_config.comment_only_line?(directive_comment.line_number)
        end

        # rubocop:disable-next Metrics/MethodLength
        def offense_message(directive_comment)
          comment = directive_comment.comment
          after_marker = comment.text.sub(DirectiveComment::DIRECTIVE_MARKER_REGEXP, '')
          mode = after_marker.split(' ', 2).first
          additional_msg = if mode.nil?
                             MISSING_MODE_NAME_MSG
                           elsif !DirectiveComment::AVAILABLE_MODES.include?(mode)
                             INVALID_MODE_NAME_MSG
                           elsif directive_comment.missing_cop_name?
                             MISSING_COP_NAME_MSG
                           else
                             MALFORMED_COP_NAMES_MSG
                           end

          "#{COMMON_MSG} #{additional_msg}"
        end

        def near_miss_keyword(comment)
          match = comment.text.match(NEAR_MISS_KEYWORD_REGEXP)
          return unless match

          keyword = match[:keyword]
          return if keyword == 'rubocop'

          keyword if similar_to_rubocop?(keyword)
        end

        def similar_to_rubocop?(keyword)
          return true if keyword.casecmp?('rubocop')
          # `DidYouMean` is not always available - see `NameSimilarity`.
          return false unless defined?(DidYouMean::Levenshtein)

          DidYouMean::Levenshtein.distance(keyword.downcase, 'rubocop') <= 2
        end

        def unknown_cop_name(directive_comment)
          return if directive_comment.push? || directive_comment.pop? || directive_comment.all_cops?

          registry = directive_comment.cop_registry
          directive_comment.raw_cop_names.find do |name|
            next false if registry.department?(name)

            qualified = registry.qualified_cop_name(name, nil, warn: false)
            !registry.contains_cop_matching?([qualified])
          end
        end

        def unknown_cop_message(directive_comment, name)
          similar = NameSimilarity.find_similar_name(name, directive_comment.cop_registry.names)
          suggestion = similar ? " (did you mean `#{similar}`?)" : ''
          format(UNKNOWN_COP_MSG, name: name, suggestion: suggestion)
        end
      end
    end
  end
end
# rubocop:enable Lint/RedundantCopDisableDirective
# rubocop:enable Style/DoubleCopDisableDirective
