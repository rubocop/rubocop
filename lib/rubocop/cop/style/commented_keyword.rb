# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comments put on the same line as some keywords.
      # These keywords are: `begin`, `class`, `def`, `end`, `module`.
      #
      # Note that some comments
      # (`:nodoc:`, `:yields:`, `rubocop:disable` and `rubocop:todo`)
      # are allowed.
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
      class CommentedKeyword < Cop
        MSG = 'Do not place comments on the same line as the ' \
              '`%<keyword>s` keyword.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            add_offense(comment) if offensive?(comment)
          end
        end

        private

        KEYWORDS = %w[begin class def end module].freeze
        KEYWORD_REGEXES = KEYWORDS.map { |w| /^\s*#{w}\s/ }.freeze

        ALLOWED_COMMENTS = %w[
          :nodoc:
          :yields:
          rubocop:disable
          rubocop:todo
        ].freeze
        ALLOWED_COMMENT_REGEXES = ALLOWED_COMMENTS.map { |c| /#\s*#{c}/ }.freeze

        def offensive?(comment)
          line = line(comment)
          KEYWORD_REGEXES.any? { |r| r.match?(line) } &&
            ALLOWED_COMMENT_REGEXES.none? { |r| r.match?(line) }
        end

        def message(comment)
          keyword = line(comment).match(/(\S+).*#/)[1]
          format(MSG, keyword: keyword)
        end

        def line(comment)
          comment.location.expression.source_line
        end
      end
    end
  end
end
