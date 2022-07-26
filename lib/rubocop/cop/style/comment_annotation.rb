# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that comment annotation keywords are written according
      # to guidelines.
      #
      # Annotation keywords can be specified by overriding the cop's `Keywords`
      # configuration. Keywords are allowed to be single words or phrases.
      #
      # NOTE: With a multiline comment block (where each line is only a
      # comment), only the first line will be able to register an offense, even
      # if an annotation keyword starts another line. This is done to prevent
      # incorrect registering of keywords (eg. `review`) inside a paragraph as an
      # annotation.
      #
      # @example RequireColon: true (default)
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
      #
      #   # bad
      #   # HACK:
      #   # does not work
      #
      #   # good
      #   # HACK: does not work
      #
      # @example RequireColon: false
      #   # bad
      #   # TODO: make better
      #
      #   # good
      #   # TODO make better
      #
      #   # bad
      #   # fixme does not work
      #
      #   # good
      #   # FIXME does not work
      #
      #   # bad
      #   # Optimize does not work
      #
      #   # good
      #   # OPTIMIZE does not work
      #
      #   # bad
      #   # HACK
      #   # does not work
      #
      #   # good
      #   # HACK does not work
      #
      class CommentAnnotation < Base
        include RangeHelp
        extend AutoCorrector

        MSG_COLON_STYLE = 'Annotation keywords like `%<keyword>s` should be all ' \
                          'upper case, followed by a colon, and a space, ' \
                          'then a note describing the problem.'
        MSG_SPACE_STYLE = 'Annotation keywords like `%<keyword>s` should be all ' \
                          'upper case, followed by a space, ' \
                          'then a note describing the problem.'
        MISSING_NOTE = 'Annotation comment, with keyword `%<keyword>s`, is missing a note.'

        def on_new_investigation
          comments = processed_source.comments
          comments.each_with_index do |comment, index|
            next unless first_comment_line?(comments, index) || inline_comment?(comment)

            annotation = AnnotationComment.new(comment, keywords)
            next unless annotation.annotation? && !annotation.correct?(colon: requires_colon?)

            register_offense(annotation, comments, index)
          end
        end

        private

        def register_offense(annotation, comments, index)
          range = annotation_range(annotation)
          message = if annotation.note
                      requires_colon? ? MSG_COLON_STYLE : MSG_SPACE_STYLE
                    else
                      MISSING_NOTE
                    end

          add_offense(range, message: format(message, keyword: annotation.keyword)) do |corrector|
            if (has_note = annotation.note.nil?) && next_line_comment?(comments, index)
              correct_offensess(corrector, range, annotation.keyword, comments[index + 1])
            end

            correct_offense(corrector, range, annotation.keyword) unless has_note
          end
        end

        def first_comment_line?(comments, index)
          index.zero? || comments[index - 1].loc.line < comments[index].loc.line - 1
        end

        def inline_comment?(comment)
          !comment_line?(comment.loc.expression.source_line)
        end

        def next_line_comment?(comments, index)
          comments[index + 1]&.loc&.line &&
            comments[index].loc.line == comments[index + 1].loc.line - 1
        end

        def annotation_range(annotation)
          range_between(*annotation.bounds)
        end

        def correct_offense(corrector, range, keyword)
          return corrector.replace(range, "#{keyword.upcase}: ") if requires_colon?

          corrector.replace(range, "#{keyword.upcase} ")
        end

        def correct_offensess(corrector, range, keyword, next_comment)
          separator = requires_colon? ? ': ' : ' '
          corrector.replace(range, "#{keyword.upcase}#{separator}")
          corrector.insert_after(range, comment_body(next_comment))
          corrector.remove(range_by_whole_lines(next_comment.loc.expression,
                                                include_final_newline: true))
        end

        def comment_body(comment)
          comment.text.gsub(/^# /, '')
        end

        def requires_colon?
          cop_config['RequireColon']
        end

        def keywords
          cop_config['Keywords']
        end
      end
    end
  end
end
