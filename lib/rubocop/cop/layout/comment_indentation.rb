# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of comments.
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
      class CommentIndentation < Base
        include Alignment
        extend AutoCorrector

        MSG = 'Incorrect indentation detected (column %<column>d ' \
          'instead of %<correct_comment_indentation>d).'

        def on_new_investigation
          processed_source.comments.each { |comment| check(comment) }
        end

        private

        def autocorrect(corrector, comment)
          autocorrect_preceding_comments(corrector, comment)

          autocorrect_one(corrector, comment)
        end

        # Corrects all comment lines that occur immediately before the given
        # comment and have the same indentation. This is to avoid a long chain
        # of correcting, saving the file, parsing and inspecting again, and
        # then correcting one more line, and so on.
        def autocorrect_preceding_comments(corrector, comment)
          comments = processed_source.comments
          index = comments.index(comment)

          comments[0..index]
            .reverse_each
            .each_cons(2)
            .take_while { |below, above| should_correct?(above, below) }
            .map { |_, above| autocorrect_one(corrector, above) }
        end

        def should_correct?(preceding_comment, reference_comment)
          loc = preceding_comment.loc
          ref_loc = reference_comment.loc
          loc.line == ref_loc.line - 1 && loc.column == ref_loc.column
        end

        def autocorrect_one(corrector, comment)
          AlignmentCorrector.correct(corrector, processed_source, comment, @column_delta)
        end

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

          add_offense(comment, message: message(column, correct_comment_indentation)) do |corrector|
            autocorrect(corrector, comment)
          end
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
          /\A\s*#/.match?(own_line)
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
          /^\s*(end\b|[)}\]])/.match?(line)
        end

        def two_alternatives?(line)
          /^\s*(else|elsif|when|rescue|ensure)\b/.match?(line)
        end
      end
    end
  end
end
