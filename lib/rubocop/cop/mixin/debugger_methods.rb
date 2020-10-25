# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to allow certain debugger methods
    # when parsing.
    module DebuggerMethods
      private

      # @api public
      def debugger_method?(name)
        debugger_methods.include?(name.to_s)
      end

      # @api public
      def debugger_methods
        cop_config.fetch('DebuggerMethods', [])
      end
    end
  end
end
