# frozen_string_literal: true

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
      #   # bad - only the first directive takes effect
      #   # rubocop:disable Layout/LineLength # rubocop:disable Style/Encoding
      #
      #   # good
      #   # rubocop:disable Layout/LineLength, Style/Encoding
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
        extend AutoCorrector

        COMMON_MSG = 'Malformed directive comment detected.'

        MISSING_MODE_NAME_MSG = 'The mode name is missing.'
        INVALID_MODE_NAME_MSG = 'The mode name must be one of `enable`, `disable`, `disable-next`, `enable-next`, `todo`, `todo-next`, `next`, `push`, or `pop`.' # rubocop:disable Layout/LineLength -- the message lists every mode and does not wrap
        MISSING_COP_NAME_MSG = 'The cop name is missing.'
        MULTIPLE_DIRECTIVES_MSG = 'Only the first directive on a line takes effect. ' \
                                  'List the cop names in a single directive instead.'
        MALFORMED_COP_NAMES_MSG = 'Cop names must be separated by commas. ' \
                                  'Comment in the directive must start with `--`.'
        INVALID_SIGNED_ARGS_MSG = '`push` and `next` arguments must be `+`- or `-`-prefixed ' \
                                  'cop names, and `pop` takes no arguments.'
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
          if (directives = multiple_directives(comment, directive_comment))
            add_offense(comment, message: "#{COMMON_MSG} #{MULTIPLE_DIRECTIVES_MSG}") do |corrector|
              merge_directives(corrector, comment, directives)
            end
          elsif directive_comment.malformed?
            add_offense(comment, message: offense_message(directive_comment))
          elsif misplaced_next_directive?(directive_comment)
            add_offense(comment, message: NEXT_DIRECTIVE_AT_EOL_MSG)
          elsif (name = unknown_cop_name(directive_comment))
            add_offense(comment, message: unknown_cop_message(directive_comment, name))
          end
        end

        # Everything after the first directive in a comment is trailing text as
        # far as the parser is concerned, so a second directive written on the
        # same line disables nothing at all. A valid `--` reason may mention a
        # directive as plain text, which should not be treated as another one.
        def multiple_directives(comment, directive_comment)
          matches = comment.text.to_enum(:scan, DirectiveComment::DIRECTIVE_COMMENT_REGEXP)
                           .map { Regexp.last_match }
          matches = filter_reason_matches(matches, directive_comment)

          matches if matches.size > 1
        end

        def filter_reason_matches(matches, directive_comment)
          return matches unless directive_comment.reason

          [matches.first, *matches.drop(1).reject { |match| match.post_match.match?(/\S/) }]
        end

        def merge_directives(corrector, comment, directives)
          return unless directives_adjacent?(comment, directives)
          return unless (mode = merged_mode(directives))
          return unless (cops = merged_cops(directives))

          corrector.replace(comment, "# rubocop:#{mode} #{cops.join(', ')}")
        end

        # `all` covers every cop already, so folding it into a list of names
        # would be a rewrite rather than a merge.
        def merged_cops(directives)
          cops = directives.flat_map { |match| match[2].to_s.split(',').map(&:strip) }
          cops = cops.reject(&:empty?).uniq
          cops unless cops.empty? || cops.include?('all')
        end

        # Anything written between the directives is a `--` reason or prose,
        # and merging around it would either move it or drop it.
        def directives_adjacent?(comment, directives)
          text = comment.text
          bounds = directives.map { |match| match.end(0) }
                             .zip(directives.map { |match| match.begin(0) }[1..] + [text.length])
          bounds.all? { |from, to| text[from...to].strip.empty? }
        end

        # `todo` is an alias of `disable`, so those two combine. Anything else
        # (an `enable` beside a `disable`, or directives of different scopes)
        # means different things per directive and can't be folded into one.
        def merged_mode(directives)
          modes = directives.map { |match| match[1] }.uniq
          return modes.first if modes.size == 1
          return modes.first if (modes - %w[disable todo]).empty?

          nil
        end

        # An EOL next-statement directive is not honored - it must fail
        # loudly instead of silently doing nothing.
        def misplaced_next_directive?(directive_comment)
          next_statement_directive?(directive_comment) &&
            !processed_source.comment_config.comment_only_line?(directive_comment.line_number)
        end

        def next_statement_directive?(directive_comment)
          directive_comment.disable_next? || directive_comment.enable_next? ||
            directive_comment.next?
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
                           elsif directive_comment.invalid_signed_args?
                             INVALID_SIGNED_ARGS_MSG
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
          return if directive_comment.pop? || directive_comment.all_cops?

          registry = directive_comment.cop_registry
          directive_names(directive_comment).find do |name|
            next false if registry.department?(name)

            qualified = registry.qualified_cop_name(name, nil, warn: false)
            !registry.contains_cop_matching?([qualified])
          end
        end

        def directive_names(directive_comment)
          if directive_comment.push? || directive_comment.next?
            directive_comment.signed_args.values.flatten
          else
            directive_comment.raw_cop_names
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
