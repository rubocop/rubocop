# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking `rescue` nodes.
    module RescueNode
      def investigate(processed_source)
        @modifier_locations = processed_source
                              .tokens
                              .select { |t| t.type == :kRESCUE_MOD }
                              .map(&:pos)
      end

      private

      def rescue_modifier?(node)
        node &&
          node.resbody_type? &&
          @modifier_locations.include?(node.loc.keyword)
      end
    end
  end
end
