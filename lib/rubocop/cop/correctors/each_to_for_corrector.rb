# frozen_string_literal: true

module RuboCop
  module Cop
    # This class autocorrects `#each` enumeration to `for` iteration.
    class EachToForCorrector
      extend NodePattern::Macros

      CORRECTION_WITH_ARGUMENTS = 'for %<variables>s in %<collection>s do'
      CORRECTION_WITHOUT_ARGUMENTS = 'for _ in %<enumerable>s do'

      def initialize(block_node)
        @block_node = block_node
        @collection_node = block_node.receiver
        @argument_node = block_node.arguments
      end

      def call(corrector)
        corrector.replace(offending_range, correction)
        corrector.replace(block_node.loc.end, closing_keyword) if block_node.braces?
      end

      private

      attr_reader :block_node, :collection_node, :argument_node

      def correction
        keyword = if block_node.arguments?
                    format(
                      CORRECTION_WITH_ARGUMENTS,
                      collection: collection_node.source,
                      variables: argument_node.children.map(&:source).join(', ')
                    )
                  else
                    format(CORRECTION_WITHOUT_ARGUMENTS, enumerable: collection_node.source)
                  end

        padding_needed?(offending_range.end_pos) ? "#{keyword} " : keyword
      end

      def closing_keyword
        padding_needed?(block_node.loc.end.begin_pos - 1) ? ' end' : 'end'
      end

      def padding_needed?(position)
        character = block_node.source_range.source_buffer.source[position]

        !character.nil? && !character.match?(/\s/)
      end

      def offending_range
        begin_range = block_node.source_range.begin

        if block_node.arguments?
          begin_range.join(argument_node.source_range.end)
        else
          begin_range.join(block_node.loc.begin.end)
        end
      end
    end
  end
end
