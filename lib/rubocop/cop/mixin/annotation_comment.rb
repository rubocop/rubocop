# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Common functionality related to annotation comments.
      module AnnotationComment
        private

        # @api public
        def annotation?(comment)
          _margin, first_word, colon, space, note = split_comment(comment)
          keyword_appearance?(first_word, colon, space) &&
            !just_first_word_of_sentence?(first_word, colon, space, note)
        end

        # @api public
        def split_comment(comment)
          match = comment.text.match(/^(# ?)([A-Za-z]+)(\s*:)?(\s+)?(\S+)?/)
          return false unless match

          match.captures
        end

        # @api public
        def keyword_appearance?(first_word, colon, space)
          first_word && keyword?(first_word.upcase) && (colon || space)
        end

        # @api private
        def just_first_word_of_sentence?(first_word, colon, space, note)
          first_word == first_word.capitalize && !colon && space && note
        end

        # @api public
        def keyword?(word)
          config.for_cop('Style/CommentAnnotation')['Keywords'].include?(word)
        end
      end
    end
  end
end
