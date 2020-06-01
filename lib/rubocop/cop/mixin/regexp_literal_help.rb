# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling Regexp literals.
    module RegexpLiteralHelp
      private

      def freespace_mode_regexp?(node)
        regopt = node.children.find(&:regopt_type?)

        regopt.children.include?(:x)
      end
    end
  end
end
