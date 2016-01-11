# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that comment annotation keywords are written according
      # to guidelines.
      class CommentAnnotation < Cop
        include AnnotationComment

        MSG = 'Annotation keywords like `%s` should be all upper case, ' \
              'followed by a colon, and a space, ' \
              'then a note describing the problem.'.freeze
        MISSING_NOTE = 'Annotation comment, with keyword `%s`, ' \
                       'is missing a note.'.freeze

        def investigate(processed_source)
          processed_source.comments.each_with_index do |comment, ix|
            next unless first_comment_line?(processed_source.comments, ix)

            margin, first_word, colon, space, note = split_comment(comment)
            next unless annotation?(comment) &&
                        !correct_annotation?(first_word, colon, space, note)

            start = comment.loc.expression.begin_pos + margin.length
            length = first_word.length + colon.to_s.length + space.to_s.length
            source_buffer = comment.loc.expression.source_buffer
            range = Parser::Source::Range.new(source_buffer,
                                              start,
                                              start + length)
            if note
              add_offense(comment, range, format(MSG, first_word))
            else
              add_offense(comment, range, format(MISSING_NOTE, first_word))
            end
          end
        end

        private

        def first_comment_line?(comments, ix)
          ix == 0 || comments[ix - 1].loc.line < comments[ix].loc.line - 1
        end

        def autocorrect(comment)
          margin, first_word, colon, space, note = split_comment(comment)
          start = comment.loc.expression.begin_pos + margin.length
          return if note.nil?

          lambda do |corrector|
            length = first_word.length + colon.to_s.length + space.to_s.length
            range = Parser::Source::Range.new(comment.loc.expression.source,
                                              start,
                                              start + length)
            corrector.replace(range, "#{first_word.upcase}: ")
          end
        end

        def correct_annotation?(first_word, colon, space, note)
          keyword?(first_word) && (colon && space && note || !colon && !note)
        end
      end
    end
  end
end
