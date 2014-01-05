# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for cops checking for missing space after
    # punctuation.
    module SpaceAfterPunctuation
      MSG = 'Space missing after %s.'

      def investigate(processed_source)
        processed_source.tokens.each_cons(2) do |t1, t2|
          if kind(t1) && t1.pos.line == t2.pos.line &&
              t2.pos.column == t1.pos.column + offset(t1)
            add_offence(t1, t1.pos, sprintf(MSG, kind(t1)))
          end
        end
      end

      # The normal offset, i.e., the distance from the punctuation
      # token where a space should be, is 1.
      def offset(token)
        1
      end

      def autocorrect(token)
        @corrections << lambda do |corrector|
          corrector.insert_after(token.pos, ' ')
        end
      end
    end
  end
end
