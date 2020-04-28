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

      # Calls the given block for all values in the `array` literal.
      #
      # @yieldparam [Node] node each node
      # @return [self] if a block is given
      # @return [Enumerator] if no block is given
      def each_value(&block)
        return to_enum(__method__) unless block_given?

        values.each(&block)

        self
      end

      # Checks whether the `array` literal is delimited by square brackets.
      #
      # @return [Boolean] whether the array is enclosed in square brackets
      def square_brackets?
        loc.begin&.is?('[')
      end

      # Checks whether the `array` literal is delimited by percent brackets.
      #
      # @overload percent_literal?
      #   Check for any percent literal.
      #
      # @overload percent_literal?(type)
      #   Check for percent literal of type `type`.
      #
      #   @param type [Symbol] an optional percent literal type
      #
      # @return [Boolean] whether the array is enclosed in percent brackets
      def percent_literal?(type = nil)
        if type
          loc.begin && loc.begin.source =~ PERCENT_LITERAL_TYPES[type]
        else
          loc.begin&.source&.start_with?('%')
        end
      end

      # Checks whether the `array` literal is delimited by either percent or
      # square brackets
      #
      # @return [Boolean] whether the array is enclosed in percent or square
      # brackets
      def bracketed?
        square_brackets? || percent_literal?
      end
    end
  end
end
