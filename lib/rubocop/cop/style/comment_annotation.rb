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

            length = concat_length(first_word, colon, space)
            add_offense(comment, annotation_range(comment, margin, length),
                        format(note ? MSG : MISSING_NOTE, first_word))
          end
        end

        private

        def first_comment_line?(comments, ix)
          ix.zero? || comments[ix - 1].loc.line < comments[ix].loc.line - 1
        end

        def autocorrect(comment)
          margin, first_word, colon, space, note = split_comment(comment)
          return if note.nil?

          length = concat_length(first_word, colon, space)
          range = annotation_range(comment, margin, length)

          ->(corrector) { corrector.replace(range, "#{first_word.upcase}: ") }
        end

        def annotation_range(comment, margin, length)
          start = comment.loc.expression.begin_pos + margin.length
          range_between(start, start + length)
        end

        def concat_length(*args)
          args.reduce(0) { |acc, elem| acc + elem.to_s.length }
        end

        def correct_annotation?(first_word, colon, space, note)
          keyword?(first_word) && (colon && space && note || !colon && !note)
        end
      end
    end
  end
end
