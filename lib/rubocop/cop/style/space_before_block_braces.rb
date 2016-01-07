# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that block braces have or don't have a space before the opening
      # brace depending on configuration.
      class SpaceBeforeBlockBraces < Cop
        include ConfigurableEnforcedStyle

        ARROW = '->'.freeze
        RIGHT_AFTER_ARROW = /\G(?<=#{Regexp.quote(ARROW)})/

        def on_block(node)
          return if node.loc.begin.is?('do') # No braces.

          # If braces are on separate lines, and the BlockDelimiters cop is
          # enabled, those braces will be changed to do..end by the user or by
          # auto-correct, so reporting space issues is not useful, and it
          # creates auto-correct conflicts.
          if config.for_cop('Style/BlockDelimiters')['Enabled'] &&
             block_length(node) > 0
            return
          end

          left_brace = node.loc.begin
          space_plus_brace = range_with_surrounding_space(left_brace)
          used_style =
            space_plus_brace.source.start_with?('{') ? :no_space : :space

          self.stabby_arrow_style_applied =
            match_at(space_plus_brace, RIGHT_AFTER_ARROW) &&
            style_after_stabby_arrow != style

          case used_style
          when enforced_style
            correct_style_detected
          when :space
            space_detected(left_brace, space_plus_brace)
          else
            space_missing(left_brace)
          end
        end

        private

        attr_accessor :stabby_arrow_style_applied

        def enforced_style
          if stabby_arrow_style_applied
            style_after_stabby_arrow
          else
            style
          end
        end

        def style_after_stabby_arrow
          @style_after_stabby_arrow ||=
            case s = cop_config['EnforcedStyleAfterStabbyArrow'].to_sym
            when :inherit
              style
            when *supported_styles_after_stabby_arrow
              s
            else
              fail "Unknown style #{s} " \
                   'for EnforcedStyleAfterStabbyArrow selected!'
            end
        end

        def supported_styles_after_stabby_arrow
          @supported_styles_after_stabby_arrow ||=
            cop_config['SupportedStylesAfterStabbyArrow'].map(&:to_sym)
        end

        def opposite_style_detected
          if stabby_arrow_style_applied
            config_to_allow_offenses['EnforcedStyleAfterStabbyArrow'] =
              (supported_styles_after_stabby_arrow -
               [style_after_stabby_arrow]).map(&:to_s)
            style_detected(style)
          else
            super
          end
        end

        def correct_style_detected
          if stabby_arrow_style_applied
            config_to_allow_offenses['EnforcedStyleAfterStabbyArrow'] =
              (supported_styles_after_stabby_arrow -
               [style]).map(&:to_s)
          end
          super
        end

        def space_missing(left_brace)
          add_offense(left_brace, left_brace,
                      'Space missing to the left of {.') do
            opposite_style_detected
          end
        end

        def space_detected(left_brace, space_plus_brace)
          space = Parser::Source::Range.new(left_brace.source_buffer,
                                            space_plus_brace.begin_pos,
                                            left_brace.begin_pos)
          add_offense(space, space, 'Space detected to the left of {.') do
            opposite_style_detected
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            case range.source
            when /\s/ then corrector.remove(range)
            else           corrector.insert_before(range, ' ')
            end
          end
        end
      end
    end
  end
end
