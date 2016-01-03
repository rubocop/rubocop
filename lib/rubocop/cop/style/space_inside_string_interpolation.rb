# encoding: utf-8

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

        NO_SPACE_MSG = 'Space inside string interpolation detected.'
        SPACE_MSG = 'Missing space around string interpolation detected.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last
            next unless final_node

            interp = final_node.source_range
            interp_with_surrounding_space = range_with_surrounding_space(interp)
            if style == :no_space
              if interp_with_surrounding_space != interp
                add_offense(final_node, :expression, NO_SPACE_MSG)
              end
            elsif style == :space
              if interp_with_surrounding_space.source != " #{interp.source} "
                add_offense(final_node, :expression, SPACE_MSG)
              end
            end
          end
        end

        private

        def autocorrect(node)
          new_source = (style == :no_space) ? node.source : " #{node.source} "
          lambda do |corrector|
            corrector.replace(range_with_surrounding_space(node.source_range),
                              new_source)
          end
        end
      end
    end
  end
end
