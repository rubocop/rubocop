# frozen_string_literal: true

module RuboCop
  module Cop
    # This class auto-corrects `for` iteration to `#each` enumeration.
    class ForToEachCorrector
      extend NodePattern::Macros

      CORRECTION = '%<collection>s.each do |%<argument>s|'

      def initialize(for_node)
        @for_node        = for_node
        @variable_node   = for_node.variable
        @collection_node = for_node.collection
      end

      def call(corrector)
        corrector.replace(offending_range, correction)
      end

      private

      attr_reader :for_node, :variable_node, :collection_node

      def correction
        format(CORRECTION, collection: collection_source,
                           argument: variable_node.source)
      end

      def collection_source
        if requires_parentheses?
          "(#{collection_node.source})"
        else
          collection_node.source
        end
      end

      def requires_parentheses?
        collection_node.range_type?
      end

      def end_position
        if for_node.do?
          keyword_begin.end_pos
        else
          collection_end.end_pos
        end
      end

      def keyword_begin
        for_node.loc.begin
      end

      def collection_end
        if collection_node.begin_type?
          collection_node.loc.end
        else
          collection_node.loc.expression
        end
      end

      def offending_range
        replacement_range(end_position)
      end

      def replacement_range(end_pos)
        Parser::Source::Range.new(for_node.loc.expression.source_buffer,
                                  for_node.loc.expression.begin_pos,
                                  end_pos)
      end
    end
  end
end
