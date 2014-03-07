# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks that the equals signs in parameter default assignments
      # have or don't have surrounding space depending on configuration.
      class SpaceAroundEqualsInParameterDefault < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          on_node(:optarg, processed_source.ast) do |optarg|
            index = index_of_first_token(optarg)
            arg, equals, value = processed_source.tokens[index, 3]
            check_optarg(arg, equals, value)
          end
        end

        private

        def check_optarg(arg, equals, value)
          space_on_both_sides = space_on_both_sides?(arg, equals, value)
          no_surrounding_space = no_surrounding_space?(arg, equals, value)

          if style == :space && space_on_both_sides ||
              style == :no_space && no_surrounding_space
            correct_style_detected
          else
            range = Parser::Source::Range.new(processed_source.buffer,
                                              arg.pos.end_pos,
                                              value.pos.begin_pos)
            add_offense(range, range) do
              if style == :space && no_surrounding_space ||
                  style == :no_space && space_on_both_sides
                opposite_style_detected
              else
                unrecognized_style_detected
              end
            end
          end
        end

        def space_on_both_sides?(arg, equals, value)
          space_between?(arg, equals) && space_between?(equals, value)
        end

        def no_surrounding_space?(arg, equals, value)
          !space_between?(arg, equals) && !space_between?(equals, value)
        end

        def message(_)
          format('Surrounding space %s in default value assignment.',
                 style == :space ? 'missing' : 'detected')
        end

        def autocorrect(range)
          replacement = style == :space ? ' = ' : '='
          @corrections << lambda do |corrector|
            corrector.replace(range, replacement)
          end
        end
      end
    end
  end
end
