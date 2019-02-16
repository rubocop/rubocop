# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Rails safe mode.
    module SafeMode
      private

      def rails?
        config['Rails'] && config['Rails'].fetch('Enabled')
      end

      def rails_safe_mode?
        safe_mode? || rails?
      end

      def safe_mode?
        cop_config['SafeMode']
      end
    end
  end
end
