# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for indentation of the first non-blank non-comment
      # line in a file.
      class InitialIndentation < Cop
        MSG = 'Indentation of first line in file detected.'.freeze

        def investigate(_processed_source)
          token = first_token
          space_before(token) { |space| add_offense(space, token.pos) }
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        def first_token
          processed_source.tokens.find { |t| !t.text.start_with?('#') }
        end

        def space_before(token)
          return unless token
          return if token.pos.column.zero?

          token_with_space =
            range_with_surrounding_space(token.pos, :left, false)
          # If the file starts with a byte order mark (BOM), the column can be
          # non-zero, but then we find out here if there's no space to the left
          # of the first token.
          return if token_with_space == token.pos

          yield range_between(token_with_space.begin_pos, token.pos.begin_pos)
        end
      end
    end
  end
end
