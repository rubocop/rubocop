# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for missing space after
    # punctuation.
    module SpaceAfterPunctuation
      MSG = 'Space missing after %<token>s.'.freeze

      def investigate(processed_source)
        each_missing_space(processed_source.tokens) do |token|
          add_offense(token, location: token.pos,
                             message: format(MSG, token: kind(token)))
        end
      end

      def each_missing_space(tokens)
        tokens.each_cons(2) do |t1, t2|
          next unless kind(t1)
          next unless space_missing?(t1, t2)
          next unless space_required_before?(t2)

          yield t1
        end
      end

      def space_missing?(t1, t2)
        t1.pos.line == t2.pos.line && t2.pos.column == t1.pos.column + offset
      end

      def space_required_before?(token)
        !(allowed_type?(token) ||
          (token.type == :tRCURLY && space_forbidden_before_rcurly?))
      end

      def allowed_type?(token)
        %i[tRPAREN tRBRACK tPIPE].include?(token.type)
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
