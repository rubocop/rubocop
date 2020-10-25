# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to forbid certain method receivers
    # when parsing.
    module ForbiddenReceivers
      private

      # @api public
      def forbidden?(name)
        forbidden_receivers.include?(name.to_s)
      end

      # @api public
      def forbidden_receivers
        cop_config.fetch('ForbiddenReceivers', [])
      end
    end
  end
end
