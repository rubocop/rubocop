# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for non-ascii characters in identifier names.
      class AsciiIdentifiers < Cop
        MSG = 'Use only ascii symbols in identifiers.'.freeze

        def investigate(processed_source)
          processed_source.tokens.each do |token|
            next unless token.type == :tIDENTIFIER && !token.text.ascii_only?
            add_offense(token, first_offense_range(token))
          end
        end

        private

        def first_offense_range(identifier)
          expression    = identifier.pos
          first_offense = first_non_ascii_chars(identifier.text)

          start_position = expression.begin_pos +
                           identifier.text.index(first_offense)
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
