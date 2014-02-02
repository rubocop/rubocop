# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Common functionality related to annotation comments.
      module AnnotationComment
        private

        def annotation?(comment)
          _margin, first_word, colon, space, note = split_comment(comment)
          keyword_appearance?(first_word, colon, space) &&
            !just_first_word_of_sentence?(first_word, colon, space, note)
        end

        def split_comment(comment)
          match = comment.text.match(/^(# ?)([A-Za-z]+)(\s*:)?(\s+)?(\S+)?/)
          return false unless match
          margin, first_word, colon, space, note = *match.captures
          [margin, first_word, colon, space, note]
        end

        def keyword_appearance?(first_word, colon, space)
          first_word && keyword?(first_word.upcase) && (colon || space)
        end

        def just_first_word_of_sentence?(first_word, colon, space, note)
          first_word == first_word.capitalize && !colon && space && note
        end

        def keyword?(word)
          config.for_cop('CommentAnnotation')['Keywords'].include?(word)
        end
      end
    end
  end
end
