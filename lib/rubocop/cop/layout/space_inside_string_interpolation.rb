# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for whitespace within string interpolations.
      #
      # @example EnforcedStyle: no_space (default)
      #   # bad
      #      var = "This is the #{ space } example"
      #
      #   # good
      #      var = "This is the #{no_space} example"
      #
      # @example EnforcedStyle: space
      #   # bad
      #      var = "This is the #{no_space} example"
      #
      #   # good
      #      var = "This is the #{ space } example"
      class SpaceInsideStringInterpolation < Base
        include Interpolation
        include SurroundingSpace
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        NO_SPACE_MSG = 'Space inside string interpolation detected.'
        SPACE_MSG = 'Missing space inside string interpolation detected.'

        def on_interpolation(begin_node)
          return if begin_node.multiline?

          delims = delimiters(begin_node)
          return if empty_brackets?(*delims)

          if style == :no_space
            no_space_offenses(begin_node, *delims, NO_SPACE_MSG)
          else
            space_offenses(begin_node, *delims, SPACE_MSG)
          end
        end

        private

        def autocorrect(corrector, begin_node)
          delims = delimiters(begin_node)

          if style == :no_space
            SpaceCorrector.remove_space(processed_source, corrector, *delims)
          else
            SpaceCorrector.add_space(processed_source, corrector, *delims)
          end
        end

        def delimiters(begin_node)
          left = processed_source.first_token_of(begin_node)
          right = processed_source.last_token_of(begin_node)
          [left, right]
        end
      end
    end
  end
end
