# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that block braces have or don't have a space before the opening
      # brace depending on configuration.
      class SpaceBeforeBlockBraces < Cop
        include ConfigurableEnforcedStyle

        def self.autocorrect_incompatible_with
          [Style::SymbolProc]
        end

        def on_block(node)
          return if node.keywords?

          left_brace = node.loc.begin
          space_plus_brace = range_with_surrounding_space(left_brace)
          used_style =
            space_plus_brace.source.start_with?('{') ? :no_space : :space

          case used_style
          when style  then correct_style_detected
          when :space then space_detected(left_brace, space_plus_brace)
          else             space_missing(left_brace)
          end
        end

        private

        def space_missing(left_brace)
          add_offense(left_brace, left_brace,
                      'Space missing to the left of {.') do
            opposite_style_detected
          end
        end

        def space_detected(left_brace, space_plus_brace)
          space = range_between(space_plus_brace.begin_pos,
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
