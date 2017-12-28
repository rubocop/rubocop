# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that comment annotation keywords are written according
      # to guidelines.
      #
      # @example
      #   # bad
      #   # TODO make better
      #
      #   # good
      #   # TODO: make better
      #
      #   # bad
      #   # TODO:make better
      #
      #   # good
      #   # TODO: make better
      #
      #   # bad
      #   # fixme: does not work
      #
      #   # good
      #   # FIXME: does not work
      #
      #   # bad
      #   # Optimize does not work
      #
      #   # good
      #   # OPTIMIZE: does not work
      class CommentAnnotation < Cop
        include AnnotationComment

        MSG = 'Annotation keywords like `%<keyword>s` should be all ' \
              'upper case, followed by a colon, and a space, ' \
              'then a note describing the problem.'.freeze
        MISSING_NOTE = 'Annotation comment, with keyword `%<keyword>s`, ' \
                       'is missing a note.'.freeze

        def investigate(processed_source)
          processed_source.comments.each_with_index do |comment, index|
            next unless first_comment_line?(processed_source.comments, index)

            margin, first_word, colon, space, note = split_comment(comment)
            next unless annotation?(comment) &&
                        !correct_annotation?(first_word, colon, space, note)

            length = concat_length(first_word, colon, space)
            add_offense(
              comment,
              location: annotation_range(comment, margin, length),
              message: format(note ? MSG : MISSING_NOTE, keyword: first_word)
            )
          end
        end

        def autocorrect(comment)
          margin, first_word, colon, space, note = split_comment(comment)
          return if note.nil?

          length = concat_length(first_word, colon, space)
          range = annotation_range(comment, margin, length)

          ->(corrector) { corrector.replace(range, "#{first_word.upcase}: ") }
        end

        private

        def first_comment_line?(comments, index)
          index.zero? ||
            comments[index - 1].loc.line < comments[index].loc.line - 1
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
