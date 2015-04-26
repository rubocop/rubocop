# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for extra/unnecessary whitespace.
      #
      # @example
      #
      #   name     = "RuboCop"
      #   website  = "https://github.com/bbatsov/rubocop"
      class ExtraSpacing < Cop
        MSG = 'Unnecessary spacing detected.'

        def investigate(processed_source)
          processed_source.tokens.each_cons(2) do |t1, t2|
            next unless t1.pos.line == t2.pos.line
            next unless t2.pos.begin_pos - 1 > t1.pos.end_pos
            buffer = processed_source.buffer
            start_pos = t1.pos.end_pos
            end_pos = t2.pos.begin_pos - 1
            range = Parser::Source::Range.new(buffer, start_pos, end_pos)
            add_offense(range, range, MSG)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
