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
      end

      private

      attr_reader :block_node, :collection_node, :argument_node

      def correction
        if block_node.arguments?
          format(CORRECTION_WITH_ARGUMENTS,
                 collection: collection_node.source,
                 variables: argument_node.children.first.source)
        else
          format(CORRECTION_WITHOUT_ARGUMENTS, enumerable: collection_node.source)
        end
      end

      def offending_range
        if block_node.arguments?
          replacement_range(argument_node.source_range.end_pos)
        else
          replacement_range(block_node.loc.begin.end_pos)
        end
      end

      def replacement_range(end_pos)
        Parser::Source::Range.new(block_node.source_range.source_buffer,
                                  block_node.source_range.begin_pos,
                                  end_pos)
      end
    end
  end
end
