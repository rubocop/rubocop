# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks that comment annotation keywords are written according
      # to guidelines.
      class CommentAnnotation < Cop
        include AnnotationComment

        MSG = 'Annotation keywords should be all upper case, followed by a ' \
              'colon and a space, then a note describing the problem.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            margin, first_word, colon, space, note = split_comment(comment)
            next unless annotation?(comment) &&
                        !correct_annotation?(first_word, colon, space, note)

            start = comment.loc.expression.begin_pos + margin.length
            length = first_word.length + (colon || '').length
            range = Parser::Source::Range.new(processed_source.buffer,
                                              start,
                                              start + length)
            add_offense(nil, range)
          end
        end

        private

        def correct_annotation?(first_word, colon, space, note)
          keyword?(first_word) && (colon && space && note || !colon && !note)
        end
      end
    end
  end
end
