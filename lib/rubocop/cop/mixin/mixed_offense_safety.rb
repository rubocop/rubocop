# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to support both safe and unsafe offenses in a cop.
    module MixedOffenseSafety
      attr_reader :offense_safety

      def add_mixed_offense(offense_node, message_node)
        return if unsafe_offense_when_safe_requested?

        add_offense(offense_node, message: message_node)
      end

      def add_mixed_autocorrectable_offense(offense_node, message_node, autocorrect_node,
                                            autocorrect_node_replacement)
        return if unsafe_offense_when_safe_requested?

        add_offense(offense_node, message: message_node) do |corrector|
          corrector.replace(autocorrect_node, autocorrect_node_replacement)
        end
      end

      private

      def safe_requested?
        @options.fetch(:safe, false) || @options.fetch(:safe_autocorrect, false)
      end

      def unsafe_offense_when_safe_requested?
        safe_requested? && !@offense_safety
      end
    end
  end
end
