# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for whitespace within string interpolations.
      #
      # Good:
      #    var = "This is the #{good} example"
      #
      # Bad:
      #    var = "This is the #{ bad } example"
      #
      class SpaceInsideStringInterpolation < Cop
        MSG = 'Space inside string interpolation detected.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last

            interp = final_node.loc.expression
            if range_with_surrounding_space(interp) != interp
              add_offense(final_node, :expression)
            end
          end
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(
              range_with_surrounding_space(node.loc.expression),
              node.loc.expression.source
            )
          end
        end
      end
    end
  end
end
