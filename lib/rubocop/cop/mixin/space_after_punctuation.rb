# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for missing space after
    # punctuation.
    module SpaceAfterPunctuation
      MSG = 'Space missing after %s.'.freeze

      def investigate(processed_source)
        processed_source.tokens.each_cons(2) do |t1, t2|
          next unless kind(t1) && t1.pos.line == t2.pos.line &&
                      t2.pos.column == t1.pos.column + offset &&
                      ![:tRPAREN, :tRBRACK, :tPIPE].include?(t2.type) &&
                      !(t2.type == :tRCURLY && space_forbidden_before_rcurly?)

          add_offense(t1, t1.pos, format(MSG, kind(t1)))
        end
      end

      def space_forbidden_before_rcurly?
        style = space_style_before_rcurly
        style == 'no_space'
      end

      # The normal offset, i.e., the distance from the punctuation
      # token where a space should be, is 1.
      def offset
        1
      end

      def autocorrect(token)
        ->(corrector) { corrector.replace(token.pos, token.pos.source + ' ') }
      end
    end
  end
end
