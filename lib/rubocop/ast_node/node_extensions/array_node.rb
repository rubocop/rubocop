# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `array` nodes.
    module ArrayNode
      PERCENT_LITERAL_TYPES = {
        string: /^%[wW]/,
        symbol: /^%[iI]/
      }.freeze

      def values
        each_child_node.to_a
      end

      def square_brackets?
        loc.begin && loc.begin.is?('[')
      end

      def percent_literal?(type = nil)
        if type
          loc.begin && loc.begin.source =~ PERCENT_LITERAL_TYPES[type]
        else
          loc.begin && loc.begin.source.start_with?('%')
        end
      end
    end
  end
end
