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
        include ConfigurableEnforcedStyle
        include RangeHelp

        NO_SPACE_MSG = 'Space inside string interpolation detected.'
        SPACE_MSG = 'Missing space around string interpolation detected.'

        def on_dstr(node)
          each_style_violation(node) do |final_node|
            add_offense(final_node)
          end
        end

        def autocorrect(node)
          new_source = style == :no_space ? node.source : " #{node.source} "
          lambda do |corrector|
            corrector.replace(
              range_with_surrounding_space(range: node.source_range),
              new_source
            )
          end
        end

        private

        def each_style_violation(node)
          node.each_child_node(:begin) do |begin_node|
            final_node = begin_node.children.last
            next unless final_node

            if style == :no_space && space_on_any_side?(final_node)
              yield final_node
            elsif style == :space && !space_on_each_side?(final_node)
              yield final_node
            end
          end
        end

        def message(_node)
          style == :no_space ? NO_SPACE_MSG : SPACE_MSG
        end

        def space_on_any_side?(node)
          interp = node.source_range
          interp_with_surrounding_space =
            range_with_surrounding_space(range: interp)

          interp_with_surrounding_space != interp
        end

        def space_on_each_side?(node)
          interp = node.source_range
          interp_with_surrounding_space =
            range_with_surrounding_space(range: interp)

          interp_with_surrounding_space.source == " #{interp.source} "
        end
      end
    end
  end
end
