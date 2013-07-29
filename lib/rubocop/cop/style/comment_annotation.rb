# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks that comment annotation keywords are written according
      # to guidelines.
      class CommentAnnotation < Cop
        MSG = 'Annotation keywords shall be all upper case, followed by a ' +
          'colon and a space, then a note describing the problem.'
        KEYWORDS = %w(TODO FIXME OPTIMIZE HACK REVIEW)

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            match = comment.text.match(/^(# ?)([A-Za-z]+)(\s*:)?(\s+)?(\S+)?/)
            if match
              margin, first_word, colon, space, note = *match.captures
              if annotation?(first_word, colon, space, note) &&
                  !correct_annotation?(first_word, colon, space, note)
                start = comment.loc.begin_pos + margin.length
                length = first_word.length + (colon || '').length
                range = Parser::Source::Range.new(processed_source.buffer,
                                                  start,
                                                  start + length)
                add_offence(:convention, range, MSG)
              end
            end
          end
        end

        private

        def annotation?(first_word, colon, space, note)
          keyword_appearance?(first_word, colon, space) &&
            !just_first_word_of_sentence?(first_word, colon, space, note)
        end

        def keyword_appearance?(first_word, colon, space)
          KEYWORDS.include?(first_word.upcase) && (colon || space)
        end

        def just_first_word_of_sentence?(first_word, colon, space, note)
          first_word == first_word.capitalize && !colon && space && note
        end

        def correct_annotation?(first_word, colon, space, note)
          KEYWORDS.include?(first_word) &&
            (colon && space && note || !colon && !note)
        end
      end
    end
  end
end
