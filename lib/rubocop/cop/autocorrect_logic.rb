# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the logic for autocorrect behavior for a cop.
    module AutocorrectLogic
      def autocorrect?
        autocorrect_requested? && support_autocorrect? && autocorrect_enabled?
      end

      def autocorrect_requested?
        @options.fetch(:auto_correct, false)
      end

      def support_autocorrect?
        respond_to?(:autocorrect, true)
      end

      def autocorrect_enabled?
        # allow turning off autocorrect on a cop by cop basis
        return true unless cop_config
        cop_config['AutoCorrect'] != false
      end
    end
  end
end
