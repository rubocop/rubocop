# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that block braces have or don't have a space before the opening
      # brace depending on configuration.
      #
      # @example
      #   # bad
      #   foo.map{ |a|
      #     a.bar.to_s
      #   }
      #
      #   # good
      #   foo.map { |a|
      #     a.bar.to_s
      #   }
      class SpaceBeforeBlockBraces < Cop
        include ConfigurableEnforcedStyle

        MISSING_MSG = 'Space missing to the left of {.'.freeze
        DETECTED_MSG = 'Space detected to the left of {.'.freeze

        def self.autocorrect_incompatible_with
          [Style::SymbolProc]
        end

        def on_block(node)
          return if node.keywords?

          left_brace = node.loc.begin
          space_plus_brace = range_with_surrounding_space(range: left_brace)
          used_style =
            space_plus_brace.source.start_with?('{') ? :no_space : :space

          if empty_braces?(node.loc)
            check_empty(left_brace, space_plus_brace, used_style)
          else
            check_non_empty(left_brace, space_plus_brace, used_style)
          end
        end

        private

        def check_empty(left_brace, space_plus_brace, used_style)
          return if style_for_empty_braces == used_style

          config_to_allow_offenses['EnforcedStyleForEmptyBraces'] =
            used_style.to_s

          if style_for_empty_braces == :space
            add_offense(left_brace, location: left_brace, message: MISSING_MSG)
          else
            space = range_between(space_plus_brace.begin_pos,
                                  left_brace.begin_pos)
            add_offense(space, location: space, message: DETECTED_MSG)
          end
        end

        def check_non_empty(left_brace, space_plus_brace, used_style)
          case used_style
          when style  then correct_style_detected
          when :space then space_detected(left_brace, space_plus_brace)
          else             space_missing(left_brace)
          end
        end

        def space_missing(left_brace)
          add_offense(left_brace, location: left_brace, message: MISSING_MSG) do
            opposite_style_detected
          end
        end

        def space_detected(left_brace, space_plus_brace)
          space = range_between(space_plus_brace.begin_pos,
                                left_brace.begin_pos)
          add_offense(space, location: space, message: DETECTED_MSG) do
            opposite_style_detected
          end
        end

        def style_for_empty_braces
          case cop_config['EnforcedStyleForEmptyBraces']
          when 'space'    then :space
          when 'no_space' then :no_space
          when nil then style
          else raise 'Unknown EnforcedStyleForEmptyBraces selected!'
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

        def empty_braces?(loc)
          loc.begin.end_pos == loc.end.begin_pos
        end
      end
    end
  end
end
