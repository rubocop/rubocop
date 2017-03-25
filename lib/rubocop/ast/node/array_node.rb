# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `array` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `array` nodes within RuboCop.
    class ArrayNode < Node
      PERCENT_LITERAL_TYPES = {
        string: /^%[wW]/,
        symbol: /^%[iI]/
      }.freeze

      # Returns an array of all value nodes in the `array` literal.
      #
      # @return [Array<Node>] an array of value nodes
      def values
        each_child_node.to_a
      end

      # Checks whether the `array` literal is delimited by square brackets.
      #
      # @return [Boolean] whether the array is enclosed in square brackets
      def square_brackets?
        loc.begin && loc.begin.is?('[')
      end

      # Checks whether the `array` literal is delimited by percent brackets.
      #
      # @overload percent_literal?
      #   Check for any percent literal.
      #
      # @overload percent_literal?(type)
      #   Check for percent literaly of type `type`.
      #
      #   @param type [Symbol] an optional percent literal type
      #
      # @return [Boolean] whether the array is enclosed in percent brackets
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
