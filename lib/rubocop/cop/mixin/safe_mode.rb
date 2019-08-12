# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Rails safe mode.
    module SafeMode
      warn 'The `SafeMode` option will be removed in `RuboCop` 0.76. ' \
        'Please update `rubocop-performance` to 1.15.0 or higher.'

      private

      def rails_safe_mode?
        safe_mode? || rails?
      end

      def safe_mode?
        cop_config['SafeMode']
      end

      def rails?
        config['Rails']&.fetch('Enabled')
      end
    end
  end
end
