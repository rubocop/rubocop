# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Bundler/OrderedGems and
    # Gemspec/OrderedDependencies.
    module OrderedGemNode
      def autocorrect(node)
        previous = previous_declaration(node)

        current_range = declaration_with_comment(node)
        previous_range = declaration_with_comment(previous)

        lambda do |corrector|
          swap_range(corrector, current_range, previous_range)
        end
      end

      private

      def case_insensitive_out_of_order?(string_a, string_b)
        string_a.downcase < string_b.downcase
      end

      def consecutive_lines(previous, current)
        first_line = get_source_range(current).first_line
        previous.source_range.last_line == first_line - 1
      end

      def register_offense(previous, current)
        message = format(
          self.class::MSG,
          previous: gem_name(current),
          current: gem_name(previous)
        )
        add_offense(current, message: message)
      end

      def gem_name(declaration_node)
        declaration_node.first_argument.str_content
      end

      def declaration_with_comment(node)
        buffer = processed_source.buffer
        begin_pos = get_source_range(node).begin_pos
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

      def get_source_range(node)
        unless cop_config['TreatCommentsAsGroupSeparators']
          first_comment = processed_source.ast_with_comments[node].first
          return first_comment.loc.expression unless first_comment.nil?
        end
        node.source_range
      end
    end
  end
end
