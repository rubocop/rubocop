# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects gem dependency order
    class OrderedGemCorrector
      extend OrderedGemNode

      class << self
        attr_reader :processed_source, :comments_as_separators

        def correct(processed_source, node,
                    previous_declaration, comments_as_separators)
          @processed_source = processed_source
          @comments_as_separators = comments_as_separators

          current_range = declaration_with_comment(node)
          previous_range = declaration_with_comment(previous_declaration)

          ->(corrector) do swap_range(corrector, current_range, previous_range) end
        end

        private

        def declaration_with_comment(node)
          buffer = processed_source.buffer
          begin_pos = get_source_range(node, comments_as_separators).begin_pos
          end_line = buffer.line_for_position(node.loc.expression.end_pos)
          end_pos = buffer.line_range(end_line).end_pos
          Parser::Source::Range.new(buffer, begin_pos, end_pos)
        end

        def swap_range(corrector, range1, range2)
          src1 = range1.source
          src2 = range2.source
          corrector.replace(range1, src2)
          corrector.replace(range2, src1)
        end
      end
    end
  end
end
