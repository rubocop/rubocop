# frozen_string_literal: true

module RuboCop
  module Cop
    # This class autocorrects `for` iteration to `#each` enumeration.
    class ForToEachCorrector
      extend NodePattern::Macros

      def initialize(for_node)
        @for_node        = for_node
        @variable_node   = for_node.variable
        @collection_node = for_node.collection
      end

      def call(corrector)
        corrector.replace(
          for_node.source_range.begin.join(collection_node.source_range.begin),
          requires_parentheses? ? '(' : ''
        )
        corrector.replace(collection_end.end.join(end_range), correction)
      end

      private

      attr_reader :for_node, :variable_node, :collection_node

      def correction
        closing_parenthesis = requires_parentheses? ? ')' : ''
        dot = collection_node.csend_type? ? '&.' : '.'

        "#{closing_parenthesis}#{dot}each do |#{block_parameters}|"
      end

      def requires_parentheses?
        return true if collection_node.send_type? && collection_node.operator_method?

        collection_node.range_type? || collection_node.operator_keyword?
      end

      def end_range
        if for_node.do?
          keyword_begin.end
        else
          collection_end.end
        end
      end

      def keyword_begin
        for_node.loc.begin
      end

      def collection_end
        if collection_node.begin_type?
          collection_node.loc.end
        else
          collection_node.source_range
        end
      end

      def block_parameters
        parameters = variable_node.source_range
        source = parameters.source

        trailing_commas_in_parentheses.reverse_each do |comma|
          source[comma.begin_pos - parameters.begin_pos, comma.size] = ''
        end
        source << ',' if trailing_comma_required?
        source
      end

      def trailing_commas_in_parentheses
        variable_node.each_node(:mlhs).filter_map do |mlhs|
          next unless mlhs.loc_is?(:end, ')')

          gap = mlhs.children.last.source_range.end.join(mlhs.loc.end.begin)
          gap if gap.source.include?(',')
        end.sort_by(&:begin_pos)
      end

      def trailing_comma_required?
        variable_node.mlhs_type? && variable_node.children.one? && !variable_node.loc.begin
      end
    end
  end
end
