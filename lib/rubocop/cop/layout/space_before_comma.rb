# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for comma (,) preceded by space.
      #
      # @example EnforcedStyle: no_space (default)
      #   # bad
      #   [1 , 2 , 3]
      #   a(1 , 2)
      #   each { |a , b| }
      #   def a(x: , y: nil); end
      #
      #   # good
      #   [1, 2, 3]
      #   a(1, 2)
      #   each { |a, b| }
      #   def a(x:, y: nil); end
      #
      # @example EnforcedStyle: space_after_colon
      #   # The `space_after_colon` style enforces that keyword arguments with
      #   # no default value have a space after the colon.
      #
      #   # bad
      #   [1 , 2 , 3]
      #   a(1 , 2)
      #   each { |a , b| }
      #   def a(x:, y: nil); end
      #
      #   # good
      #   [1, 2, 3]
      #   a(1, 2)
      #   each { |a, b| }
      #   def a(x: , y: nil); end
      #
      class SpaceBeforeComma < Cop
        include SpaceBeforePunctuation
        include ConfigurableEnforcedStyle

        MSG_SPACE_AFTER_COLON = 'No space found after colon.'

        def kind(token)
          'comma' if token.comma?
        end

        def autocorrect(pos)
          if @space_missing
            ->(corrector) { corrector.replace(pos, pos.source + ' ') }
          else
            super
          end
        end

        private

        def violation?(token1, token2)
          if space_required_after_kwarg?(token1)
            @space_missing = space_missing?(token1, token2)
          else
            super
          end
        end

        def space_required_after_kwarg?(token)
          style == :space_after_colon && node_at_pos(token.pos)&.kwarg_type?
        end

        def node_at_pos(pos)
          processed_source.ast.descendants.detect do |arg|
            arg.source_range == pos
          end
        end

        def space_missing?(token1, token2)
          token1.line == token2.line && !token1.space_after?
        end

        def pos_before_punctuation(token1, token2)
          if @space_missing
            range_between(token1.end_pos - 1, token2.begin_pos)
          else
            super
          end
        end

        def message_for(token)
          @space_missing ? MSG_SPACE_AFTER_COLON : super
        end
      end
    end
  end
end
