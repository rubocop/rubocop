# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comments put on the same line as some keywords.
      # These keywords are: `class`, `module`, `def`, `begin`, `end`.
      #
      # Note that some comments
      # (`:nodoc:`, `:yields:`, `rubocop:disable` and `rubocop:todo`)
      # are allowed.
      #
      # Auto-correction removes comments from `end` keyword and keeps comments
      # for `class`, `module`, `def` and `begin` above the keyword.
      #
      # @example
      #   # bad
      #   if condition
      #     statement
      #   end # end if
      #
      #   # bad
      #   class X # comment
      #     statement
      #   end
      #
      #   # bad
      #   def x; end # comment
      #
      #   # good
      #   if condition
      #     statement
      #   end
      #
      #   # good
      #   class X # :nodoc:
      #     y
      #   end
      class CommentedKeyword < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Do not place comments on the same line as the ' \
              '`%<keyword>s` keyword.'

        KEYWORDS = %w[begin class def end module].freeze
        KEYWORD_REGEXES = KEYWORDS.map { |w| /^\s*#{w}\s/ }.freeze

        ALLOWED_COMMENTS = %w[
          :nodoc:
          :yields:
          rubocop:disable
          rubocop:todo
        ].freeze
        ALLOWED_COMMENT_REGEXES = ALLOWED_COMMENTS.map { |c| /#\s*#{c}/ }.freeze

        def on_new_investigation
          processed_source.comments.each do |comment|
            next unless (match = line(comment).match(/(?<keyword>\S+).*#/)) && offensive?(comment)

            register_offense(comment, match[:keyword])
          end
        end

        private

        def register_offense(comment, matched_keyword)
          add_offense(comment, message: format(MSG, keyword: matched_keyword)) do |corrector|
            range = range_with_surrounding_space(range: comment.loc.expression, newlines: false)
            corrector.remove(range)

            unless matched_keyword == 'end'
              corrector.insert_before(
                range.source_buffer.line_range(comment.loc.line), "#{comment.text}\n"
              )
            end
          end
        end

        def offensive?(comment)
          line = line(comment)
          KEYWORD_REGEXES.any? { |r| r.match?(line) } &&
            ALLOWED_COMMENT_REGEXES.none? { |r| r.match?(line) }
        end

        def line(comment)
          comment.location.expression.source_line
        end
      end
    end
  end
end
