# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for whitespace within string interpolations.
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
      class SpaceInsideStringInterpolation < Cop
        include Interpolation
        include SurroundingSpace
        include ConfigurableEnforcedStyle
        include RangeHelp

        NO_SPACE_MSG = 'Space inside string interpolation detected.'
        SPACE_MSG = 'Missing space inside string interpolation detected.'

        def on_interpolation(begin_node)
          delims = delimiters(begin_node)
          return if empty_brackets?(*delims)

          if style == :no_space
            no_space_offenses(begin_node, *delims, NO_SPACE_MSG)
          else
            space_offenses(begin_node, *delims, SPACE_MSG)
          end
        end

        def autocorrect(begin_node)
          lambda do |corrector|
            delims = delimiters(begin_node)

            if style == :no_space
              SpaceCorrector.remove_space(processed_source, corrector, *delims)
            else
              SpaceCorrector.add_space(processed_source, corrector, *delims)
            end
          end
        end

        private

        def delimiters(begin_node)
          left = processed_source.tokens[index_of_first_token(begin_node)]
          right = processed_source.tokens[index_of_last_token(begin_node)]
          [left, right]
        end
      end
    end
  end
end
