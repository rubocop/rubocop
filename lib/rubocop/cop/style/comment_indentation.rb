# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of comments.
      class CommentIndentation < Cop
        include AutocorrectAlignment

        MSG = 'Incorrect indentation detected (column %d instead of %d).'.freeze

        def investigate(processed_source)
          processed_source.comments.each { |comment| check(comment) }
        end

        private

        def check(comment)
          lines = processed_source.lines
          own_line = lines[comment.loc.line - 1]
          return unless own_line =~ /\A\s*#/

          next_line = lines[comment.loc.line..-1].find { |line| !line.blank? }
          correct_comment_indentation = correct_indentation(next_line)
          column = comment.loc.column

          @column_delta = correct_comment_indentation - column
          return if @column_delta == 0

          if two_alternatives?(next_line)
            # Try the other
            correct_comment_indentation += configured_indentation_width
            # We keep @column_delta unchanged so that autocorrect changes to
            # the preferred style of aligning the comment with the keyword.
          end

          return if column == correct_comment_indentation
          add_offense(comment, comment.loc.expression,
                      format(MSG, column, correct_comment_indentation))
        end

        def correct_indentation(next_line)
          return 0 unless next_line

          indentation_of_next_line = next_line =~ /\S/
          indentation_of_next_line + if less_indented?(next_line)
                                       configured_indentation_width
                                     else
                                       0
                                     end
        end

        def less_indented?(line)
          line =~ /^\s*(end\b|[\}\]])/
        end

        def two_alternatives?(line)
          line =~ /^\s*(else|elsif|when|rescue|ensure)\b/
        end
      end
    end
  end
end
