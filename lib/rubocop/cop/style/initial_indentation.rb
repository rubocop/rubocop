# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks for indentation of the first non-blank non-comment
      # line in a file.
      class InitialIndentation < Cop
        MSG = 'Indentation of first line in file detected.'.freeze

        def investigate(processed_source)
          first_token = processed_source.tokens.find do |t|
            !t.text.start_with?('#')
          end
          return unless first_token
          return if first_token.pos.column == 0

          with_space = range_with_surrounding_space(first_token.pos, :left,
                                                    nil, !:with_newline)
          # If the file starts with a byte order mark (BOM), the column can be
          # non-zero, but then we find out here if there's no space to the left
          # of the first token.
          return if with_space == first_token.pos

          space = Parser::Source::Range.new(processed_source.buffer,
                                            with_space.begin_pos,
                                            first_token.pos.begin_pos)
          add_offense(space, first_token.pos)
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
