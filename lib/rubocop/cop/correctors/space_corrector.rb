# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects whitespace
    class SpaceCorrector
      extend SurroundingSpace

      class << self
        attr_reader :processed_source

        def empty_corrections(processed_source, corrector, empty_config,
                              left_token, right_token)
          @processed_source = processed_source
          if offending_empty_space?(empty_config, left_token, right_token)
            range = side_space_range(range: left_token.pos, side: :right)
            corrector.remove(range)
            corrector.insert_after(left_token.pos, ' ')
          elsif offending_empty_no_space?(empty_config, left_token, right_token)
            range = side_space_range(range: left_token.pos, side: :right)
            corrector.remove(range)
          end
        end

        def remove_space(processed_source, corrector, left_token, right_token)
          @processed_source = processed_source
          if left_token.space_after?
            range = side_space_range(range: left_token.pos, side: :right)
            corrector.remove(range)
          end
          return unless right_token.space_before?

          range = side_space_range(range: right_token.pos, side: :left)
          corrector.remove(range)
        end

        def add_space(processed_source, corrector, left_token, right_token)
          @processed_source = processed_source
          unless left_token.space_after?
            corrector.insert_after(left_token.pos, ' ')
          end
          return if right_token.space_before?

          corrector.insert_before(right_token.pos, ' ')
        end
      end
    end
  end
end
