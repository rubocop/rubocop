# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that comment annotation keywords are written according
      # to guidelines.
      #
      # NOTE: With a multiline comment block (where each line is only a
      # comment), only the first line will be able to register an offense, even
      # if an annotation keyword starts another line. This is done to prevent
      # incorrect registering of keywords (eg. `review`) inside a paragraph as an
      # annotation.
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
      class CommentAnnotation < Base
        include AnnotationComment
        include RangeHelp
        extend AutoCorrector

        MSG = 'Annotation keywords like `%<keyword>s` should be all ' \
              'upper case, followed by a colon, and a space, ' \
              'then a note describing the problem.'
        MISSING_NOTE = 'Annotation comment, with keyword `%<keyword>s`, ' \
                       'is missing a note.'

        def on_new_investigation
          processed_source.comments.each_with_index do |comment, index|
            next unless first_comment_line?(processed_source.comments, index) ||
                        inline_comment?(comment)

            margin, first_word, colon, space, note = split_comment(comment)
            next unless annotation?(comment) &&
                        !correct_annotation?(first_word, colon, space, note)

            range = annotation_range(comment, margin, first_word, colon, space)

            register_offense(range, note, first_word)
          end
        end

        private

        def register_offense(range, note, first_word)
          add_offense(
            range,
            message: format(note ? MSG : MISSING_NOTE, keyword: first_word)
          ) do |corrector|
            next if note.nil?

            corrector.replace(range, "#{first_word.upcase}: ")
          end
        end

        def first_comment_line?(comments, index)
          index.zero? ||
            comments[index - 1].loc.line < comments[index].loc.line - 1
        end

        def inline_comment?(comment)
          !comment_line?(comment.loc.expression.source_line)
        end

        def annotation_range(comment, margin, first_word, colon, space)
          start = comment.loc.expression.begin_pos + margin.length
          length = concat_length(first_word, colon, space)
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
