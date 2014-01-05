# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for checking for spaces inside various
    # kinds of parentheses.
    module SpaceInside
      include SurroundingSpace
      MSG = 'Space inside %s detected.'

      def investigate(processed_source)
        @processed_source = processed_source
        left, right, kind = specifics
        processed_source.tokens.each_cons(2) do |t1, t2|
          if t1.type == left || t2.type == right
            if t2.pos.line == t1.pos.line && space_between?(t1, t2)
              range = Parser::Source::Range.new(processed_source.buffer,
                                                t1.pos.end_pos,
                                                t2.pos.begin_pos)
              add_offence(range, range, format(MSG, kind))
            end
          end
        end
      end

      def autocorrect(range)
        @corrections << ->(corrector) { corrector.remove(range) }
      end
    end
  end
end
