# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides a list of methods that are either in the NilClass,
    # or in the cop's configuration parameter Whitelist.
    module NilMethods
      private

      def nil_methods
        nil.methods + whitelist
      end

      def whitelist
        cop_config['Whitelist'].map(&:to_sym)
      end
    end
  end
end
