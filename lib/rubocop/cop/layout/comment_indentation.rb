# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks the indentation of comments.
      #
      # @example
      #   # bad
      #     # comment here
      #   def method_name
      #   end
      #
      #     # comment here
      #   a = 'hello'
      #
      #   # yet another comment
      #     if true
      #       true
      #     end
      #
      #   # good
      #   # comment here
      #   def method_name
      #   end
      #
      #   # comment here
      #   a = 'hello'
      #
      #   # yet another comment
      #   if true
      #     true
      #   end
      #
      class CommentIndentation < Cop
        include Alignment

        MSG = 'Incorrect indentation detected (column %<column>d ' \
          'instead of %<correct_comment_indentation>d).'.freeze

        def investigate(processed_source)
          processed_source.each_comment { |comment| check(comment) }
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, @column_delta)
        end

        private

        def check(comment)
          return unless own_line_comment?(comment)

          next_line = line_after_comment(comment)
          correct_comment_indentation = correct_indentation(next_line)
          column = comment.loc.column

          @column_delta = correct_comment_indentation - column
          return if @column_delta.zero?

          if two_alternatives?(next_line)
            # Try the other
            correct_comment_indentation += configured_indentation_width
            # We keep @column_delta unchanged so that autocorrect changes to
            # the preferred style of aligning the comment with the keyword.
            return if column == correct_comment_indentation
          end

          add_offense(
            comment,
            message: message(column, correct_comment_indentation)
          )
        end

        def message(column, correct_comment_indentation)
          format(
            MSG,
            column: column,
            correct_comment_indentation: correct_comment_indentation
          )
        end

        def own_line_comment?(comment)
          own_line = processed_source.lines[comment.loc.line - 1]
          own_line =~ /\A\s*#/
        end

        def line_after_comment(comment)
          lines = processed_source.lines
          lines[comment.loc.line..-1].find { |line| !line.blank? }
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
          line =~ /^\s*(end\b|[)}\]])/
        end

        def two_alternatives?(line)
          line =~ /^\s*(else|elsif|when|rescue|ensure)\b/
        end
      end
    end
  end
end
