# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for whitespace within string interpolations.
      #
      # @example
      #   # Good if EnforcedStyle is no_space, bad if space.
      #      var = "This is the #{no_space} example"
      #
      #   # Good if EnforceStyle is space, bad if no_space.
      #      var = "This is the #{ space } example"
      class SpaceInsideStringInterpolation < Cop
        include ConfigurableEnforcedStyle

        NO_SPACE_MSG = 'Space inside string interpolation detected.'.freeze
        SPACE_MSG = 'Missing space around string interpolation detected.'.freeze

        def on_dstr(node)
          each_style_violation(node) do |final_node, msg|
            add_offense(final_node, :expression, msg)
          end
        end

        private

        def each_style_violation(node)
          node.each_child_node(:begin) do |begin_node|
            final_node = begin_node.children.last
            next unless final_node

            if style == :no_space && space_on_any_side?(final_node)
              yield final_node, NO_SPACE_MSG
            elsif style == :space && !space_on_each_side?(final_node)
              yield final_node, SPACE_MSG
            end
          end
        end

        def space_on_any_side?(node)
          interp = node.source_range
          interp_with_surrounding_space = range_with_surrounding_space(interp)

          interp_with_surrounding_space != interp
        end

        def space_on_each_side?(node)
          interp = node.source_range
          interp_with_surrounding_space = range_with_surrounding_space(interp)

          interp_with_surrounding_space.source == " #{interp.source} "
        end

        def autocorrect(node)
          new_source = style == :no_space ? node.source : " #{node.source} "
          lambda do |corrector|
            corrector.replace(range_with_surrounding_space(node.source_range),
                              new_source)
          end
        end
      end
    end
  end
end
