# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for space before
    # punctuation.
    module SpaceBeforePunctuation
      MSG = 'Space found before %s.'.freeze

      def investigate(processed_source)
        each_missing_space(processed_source.tokens) do |token, pos_before|
          add_offense(pos_before, pos_before, format(MSG, kind(token)))
        end
      end

      def each_missing_space(tokens)
        tokens.each_cons(2) do |t1, t2|
          next unless kind(t2)
          next unless space_missing?(t1, t2)
          next if space_required_after?(t1)

          pos_before_punctuation = range_between(t1.pos.end_pos,
                                                 t2.pos.begin_pos)

          yield t2, pos_before_punctuation
        end
      end

      def space_missing?(t1, t2)
        t1.pos.line == t2.pos.line && t2.pos.begin_pos > t1.pos.end_pos
      end

      def space_required_after?(token)
        token.type == :tLCURLY && space_required_after_lcurly?
      end

      def space_required_after_lcurly?
        cfg = config.for_cop('Layout/SpaceInsideBlockBraces')
        style = cfg['EnforcedStyle'] || 'space'
        style == 'space'
      end

      def autocorrect(pos_before_punctuation)
        ->(corrector) { corrector.remove(pos_before_punctuation) }
      end
    end
  end
end
