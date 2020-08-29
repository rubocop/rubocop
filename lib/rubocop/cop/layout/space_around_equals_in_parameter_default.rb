# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that the equals signs in parameter default assignments
      # have or don't have surrounding space depending on configuration.
      #
      # @example EnforcedStyle: space (default)
      #   # bad
      #   def some_method(arg1=:default, arg2=nil, arg3=[])
      #     # do something...
      #   end
      #
      #   # good
      #   def some_method(arg1 = :default, arg2 = nil, arg3 = [])
      #     # do something...
      #   end
      #
      # @example EnforcedStyle: no_space
      #   # bad
      #   def some_method(arg1 = :default, arg2 = nil, arg3 = [])
      #     # do something...
      #   end
      #
      #   # good
      #   def some_method(arg1=:default, arg2=nil, arg3=[])
      #     # do something...
      #   end
      class SpaceAroundEqualsInParameterDefault < Base
        include SurroundingSpace
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        MSG = 'Surrounding space %<type>s in default value assignment.'

        def on_optarg(node)
          index = index_of_first_token(node)
          arg, equals, value = processed_source.tokens[index, 3]
          check_optarg(arg, equals, value)
        end

        private

        def check_optarg(arg, equals, value)
          space_on_both_sides = space_on_both_sides?(arg, equals)
          no_surrounding_space = no_surrounding_space?(arg, equals)

          if style == :space && space_on_both_sides ||
             style == :no_space && no_surrounding_space
            correct_style_detected
          else
            incorrect_style_detected(arg, value, space_on_both_sides,
                                     no_surrounding_space)
          end
        end

        def incorrect_style_detected(arg, value, space_on_both_sides,
                                     no_surrounding_space)
          range = range_between(arg.end_pos, value.begin_pos)

          if style == :space && no_surrounding_space ||
             style == :no_space && space_on_both_sides
            return unless opposite_style_detected
          else
            return unless unrecognized_style_detected
          end

          add_offense(range) do |corrector|
            autocorrect(corrector, range)
          end
        end

        def autocorrect(corrector, range)
          m = range.source.match(/=\s*(\S+)/)
          rest = m ? m.captures[0] : ''
          replacement = style == :space ? ' = ' : '='

          corrector.replace(range, replacement + rest)
        end

        def space_on_both_sides?(arg, equals)
          arg.space_after? && equals.space_after?
        end

        def no_surrounding_space?(arg, equals)
          !arg.space_after? && !equals.space_after?
        end

        def message(_node)
          format(MSG, type: style == :space ? 'missing' : 'detected')
        end
      end
    end
  end
end
