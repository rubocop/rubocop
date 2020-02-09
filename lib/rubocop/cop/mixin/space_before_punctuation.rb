# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for space before
    # punctuation.
    module SpaceBeforePunctuation
      include RangeHelp

      MSG = 'Space found before %<token>s.'

      def investigate(processed_source)
        each_violation(processed_source.tokens) do |token, pos_before|
          add_offense(pos_before, location: pos_before,
                                  message: message_for(token))
        end
      end

      def autocorrect(space)
        PunctuationCorrector.remove_space(space)
      end

      private

      def each_violation(tokens)
        tokens.each_cons(2) do |token1, token2|
          next unless kind(token2) && violation?(token1, token2)

          yield token2, pos_before_punctuation(token1, token2)
        end
      end

      def violation?(token1, token2)
        space_present?(token1, token2) && !space_required_after?(token1)
      end

      def space_present?(token1, token2)
        token1.line == token2.line && token2.begin_pos > token1.end_pos
      end

      def space_required_after?(token)
        token.left_curly_brace? && space_required_after_lcurly?
      end

      def space_required_after_lcurly?
        cfg = config.for_cop('Layout/SpaceInsideBlockBraces')
        style = cfg['EnforcedStyle'] || 'space'
        style == 'space'
      end

      def pos_before_punctuation(token1, token2)
        range_between(token1.end_pos, token2.begin_pos)
      end

      def message_for(token)
        format(MSG, token: kind(token))
      end
    end
  end
end
