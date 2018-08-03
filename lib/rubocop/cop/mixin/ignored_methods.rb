# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to ignore certain methods when
    # parsing.
    module IgnoredMethods
      private

      def ignored_method?(name)
        ignored_methods.include?(name.to_s)
      end

      def ignored_methods
        cop_config.fetch('IgnoredMethods', [])
      end
    end
  end
end
