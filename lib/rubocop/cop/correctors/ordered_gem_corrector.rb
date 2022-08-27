# frozen_string_literal: true

module RuboCop
  module Cop
    # This autocorrects gem dependency order
    class OrderedGemCorrector
      class << self
        include OrderedGemNode
        include RangeHelp

        attr_reader :processed_source, :comments_as_separators

        def correct(processed_source, node,
                    previous_declaration, comments_as_separators)
          @processed_source = processed_source
          @comments_as_separators = comments_as_separators

          current_range = declaration_with_comment(node)
          previous_range = declaration_with_comment(previous_declaration)

          ->(corrector) { swap_range(corrector, current_range, previous_range) }
        end

        private

        def declaration_with_comment(node)
          buffer = processed_source.buffer
          begin_pos = range_by_whole_lines(get_source_range(node, comments_as_separators)).begin_pos
          end_line = buffer.line_for_position(node.loc.expression.end_pos)
          end_pos = range_by_whole_lines(buffer.line_range(end_line),
                                         include_final_newline: true).end_pos

          range_between(begin_pos, end_pos)
        end

        def swap_range(corrector, range1, range2)
          corrector.insert_before(range2, range1.source)
          corrector.remove(range1)
        end
      end
    end
  end
end
