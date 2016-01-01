# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking for space before
    # punctuation.
    module SpaceBeforePunctuation
      MSG = 'Space found before %s.'.freeze

      def investigate(processed_source)
        processed_source.tokens.each_cons(2) do |t1, t2|
          next unless kind(t2) && t1.pos.line == t2.pos.line &&
                      t2.pos.begin_pos > t1.pos.end_pos &&
                      !(t1.type == :tLCURLY && space_required_after_lcurly?)
          buffer = processed_source.buffer
          pos_before_punctuation = Parser::Source::Range.new(buffer,
                                                             t1.pos.end_pos,
                                                             t2.pos.begin_pos)

          add_offense(pos_before_punctuation,
                      pos_before_punctuation,
                      format(MSG, kind(t2)))
        end
      end

      def space_required_after_lcurly?
        cfg = config.for_cop('Style/SpaceInsideBlockBraces')
        style = cfg['EnforcedStyle'] || 'space'
        style == 'space'
      end

      def autocorrect(pos_before_punctuation)
        ->(corrector) { corrector.remove(pos_before_punctuation) }
      end
    end
  end
end
