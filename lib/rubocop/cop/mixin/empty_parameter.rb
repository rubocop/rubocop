# frozen_string_literal: true

module RuboCop
  module Cop
    # Common code for empty parameter cops.
    module EmptyParameter
      extend NodePattern::Macros

      private

      def_node_matcher :empty_arguments?, <<-PATTERN
        (block _ $(args) _)
      PATTERN

      def check(node)
        empty_arguments?(node) do |args|
          return if args.empty_and_without_delimiters?
          add_offense(args)
        end
      end
    end
  end
end
