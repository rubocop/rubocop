# encoding: utf-8

module RuboCop
  module Cop
    # Functions for checking the alignment of the `end` keyword.
    module EndKeywordAlignment
      include ConfigurableEnforcedStyle

      MSG = '`end` at %d, %d is not aligned with `%s` at %d, %d'

      private

      def check_offset_of_node(node)
        check_offset(node, node.loc.keyword.source, 0)
      end

      def check_offset(node, alignment_base, offset)
        return if ignored_node?(node)

        end_loc = node.loc.end
        return unless end_loc # Discard modifier forms of if/while/until.

        kw_loc = node.loc.keyword

        if kw_loc.line != end_loc.line &&
           kw_loc.column != end_loc.column + offset
          add_offense(nil, end_loc,
                      format(MSG, end_loc.line, end_loc.column,
                             alignment_base, kw_loc.line, kw_loc.column)) do
            opposite_style_detected
          end
        else
          correct_style_detected
        end
      end

      def parameter_name
        'AlignWith'
      end
    end
  end
end
