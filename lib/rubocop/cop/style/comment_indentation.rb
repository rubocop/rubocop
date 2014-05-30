# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of comments.
      class CommentIndentation < Cop
        include AutocorrectAlignment

        MSG = 'Incorrect indentation detected (column %d instead of %d).'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            lines = processed_source.lines
            own_line = lines[comment.loc.line - 1]
            next unless own_line =~ /\A\s*#/

            next_line =
              lines[comment.loc.line..-1].find { |line| !line.blank? }

            correct_comment_indentation = correct_indentation(next_line)
            column = comment.loc.column

            @column_delta = correct_comment_indentation - column
            next if @column_delta == 0

            if two_alternatives?(next_line)
              correct_comment_indentation +=
                IndentationWidth::CORRECT_INDENTATION # Try the other
              # We keep @column_delta unchanged so that autocorrect changes to
              # the preferred style of aligning the comment with the keyword.
            end

            next if column == correct_comment_indentation
            add_offense(comment, comment.loc.expression,
                        format(MSG, column, correct_comment_indentation))
          end
        end

        private

        def correct_indentation(next_line)
          return 0 unless next_line

          indentation_of_next_line = next_line =~ /\S/
          indentation_of_next_line + if less_indented?(next_line)
                                       IndentationWidth::CORRECT_INDENTATION
                                     else
                                       0
                                     end
        end

        def less_indented?(line)
          keyword = 'end\b'
          bracket = '[}\]]'
          line =~ /^\s*(#{keyword}|#{bracket})/
        end

        def two_alternatives?(line)
          keyword = '(else|elsif|when|rescue|ensure)\b'
          line =~ /^\s*#{keyword}/
        end
      end
    end
  end
end
