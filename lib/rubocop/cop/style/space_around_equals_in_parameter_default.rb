# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks that the equals signs in parameter default assignments
      # have surrounding space.
      class SpaceAroundEqualsInParameterDefault < Cop
        include SurroundingSpace
        MSG = 'Surrounding space missing in default value assignment.'

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source
          on_node(:optarg, processed_source.ast) do |optarg|
            index = index_of_first_token(optarg)
            arg, equals, value = processed_source.tokens[index, 3]
            unless space_between?(arg, equals) && space_between?(equals, value)
              add_offence(equals.pos, equals.pos)
            end
          end
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            corrector.insert_before(range, ' ')
            corrector.insert_after(range, ' ')
          end
        end
      end
    end
  end
end
