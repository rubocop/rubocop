# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for checking for spaces inside various
    # kinds of parentheses.
    module SpaceInside
      include SurroundingSpace
      MSG = 'Space inside %s detected.'

      def investigate(processed_source)
        @processed_source = processed_source
        _, right, kind = specifics
        processed_source.tokens.each_cons(2) do |t1, t2|
          next unless left?(t1.type) || t2.type == right

          # If the second token is a comment, that means that a line break
          # follows, and that the rules for space inside don't apply.
          next if t2.type == :tCOMMENT
          next unless t2.pos.line == t1.pos.line && space_between?(t1, t2)

          range = Parser::Source::Range.new(processed_source.buffer,
                                            t1.pos.end_pos,
                                            t2.pos.begin_pos)
          add_offense(range, range, format(MSG, kind))
        end
      end

      def autocorrect(range)
        @corrections << ->(corrector) { corrector.remove(range) }
      end

      private

      def left?(token_type)
        @left_types ||= [specifics.first].flatten
        @left_types.include?(token_type)
      end
    end
  end
end
