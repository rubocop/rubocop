# frozen_string_literal: true

# rubocop:disable Style/AsciiComments

module RuboCop
  module Cop
    module Style
      # This cop checks for non-ascii (non-English) characters
      # in comments.
      #
      # @example
      #   # bad
      #   # Translates from English to 日本語。
      #
      #   # good
      #   # Translates from English to Japanese
      class AsciiComments < Cop
        MSG = 'Use only ascii symbols in comments.'.freeze

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            unless comment.text.ascii_only?
              add_offense(comment, location: first_offense_range(comment))
            end
          end
        end

        private

        def first_offense_range(comment)
          expression    = comment.loc.expression
          first_offense = first_non_ascii_chars(comment.text)

          start_position = expression.begin_pos +
                           comment.text.index(first_offense)
          end_position   = start_position + first_offense.length

          range_between(start_position, end_position)
        end

        def first_non_ascii_chars(string)
          string.match(/[^[:ascii:]]+/).to_s
        end
      end
    end
  end
end
