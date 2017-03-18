# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      MACRO_PARENT_NODES = %i(class module).freeze

      # The receiving node of the method invocation.
      #
      # @return [Node, nil] the receiver of the invoked method or `nil`
      def receiver
        node_parts[0]
      end

      # The name of the invoked method called as a string.
      #
      # @return [Symbol] the name of the invoked method
      def method_name
        node_parts[1]
      end

      # Checks whether the method name matches the argument.
      #
      # @param [Symbol|String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def method?(name)
        method_name == name.to_sym
      end

      # Checks whether the method is a macro method. A macro method is defined
      # as a method that sits in a class- or module body and has an implicit
      # receiver.
      #
      # @note This does not include DSLs that use nested blocks, like RSpec
      #
      # @return [Boolean] whether the method is a macro method
      def macro?
        !receiver && MACRO_PARENT_NODES.include?(parent && parent.type)
      end

      # Checks whether the method name matches the argument and has an
      # implicit receiver.
      #
      # @param [Symbol|String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def command?(name)
        !receiver && method?(name)
      end

      # An array containing the arguments of the method invocation.
      #
      # @return [Array<Node>] the arguments of the method invocation or `nil`
      def arguments
        node_parts[2..-1]
      end

      # A shorthand for getting the first argument of the method invocation.
      # Equivalent to `arguments.first`.
      #
      # @return [Node, nil] the first argument of the method invocation,
      #                     or `nil` if there are no arguments
      def first_argument
        arguments[0]
      end

      # A shorthand for getting the last argument of the method invocation.
      # Equivalent to `arguments.last`.
      #
      # @return [Node, nil] the last argument of the method invocation,
      #                     or `nil` if there are no arguments
      def last_argument
        arguments[-1]
      end

      # Checks whether this method was invoked with arguments.
      #
      # @return [Boolean] whether this method was invoked with arguments
      def arguments?
        !arguments.empty?
      end

      # Checks whether this method invocation's arguments are wrapped in
      # parentheses.
      #
      # @return [Boolean] whether this method invocation's arguments are
      #                   wrapped in parentheses
      def parenthesized?
        loc.end && loc.end.is?(')')
      end

      # Checks whether the invoked method is a setter method.
      #
      # @return [Boolean] whether the invoked method is a setter
      def setter_method?
        loc.operator
      end

      # Checks whether the invoked method is an operator method.
      #
      # @return [Boolean] whether the invoked method is an operator
      def operator_method?
        RuboCop::Cop::Util::OPERATOR_METHODS.include?(method_name)
      end

      # Checks whether the method call uses a dot to connect the receiver and
      # the method name.
      #
      # This is useful for comparison operators, which can be called either
      # with or without a dot, i.e. `foo == bar` or `foo.== bar`.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def dot?
        loc.dot && loc.dot.is?('.')
      end

      # Checks whether the method call uses a double colon to connect the
      # receiver and the method name.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def double_colon?
        loc.dot && loc.dot.is?('::')
      end

      # Checks whether the receiver of this method invocation is `self`.
      #
      # @return [Boolean] whether the receiver of this method invocation
      #                   is `self`
      def self_receiver?
        receiver && receiver.self_type?
      end

      # Checks whether the method call is of the implicit form of `#call`,
      # e.g. `foo.(bar)`.
      #
      # @return [Boolean] whether the method is an implicit form of `#call`
      def implicit_call?
        method_name == :call && !loc.selector
      end

      # Checks whether the invoked method is a predicate method.
      #
      # @return [Boolean] whether the invoked method is a predicate method
      def predicate_method?
        method_name.to_s.end_with?('?')
      end

      # Checks whether the invoked method is a bang method.
      #
      # @return [Boolean] whether the invoked method is a bang method
      def bang_method?
        method_name.to_s.end_with?('!')
      end

      # Checks whether the invoked method is a camel case method,
      # e.g. `Integer()`.
      #
      # @return [Boolean] whether the invoked method is a camel case method
      def camel_case_method?
        method_name.to_s =~ /\A[A-Z]/
      end

      # Whether the last argument of the method invocation is a block pass,
      # i.e. `&block`.
      #
      # @return [Boolean] whether the invoked method is a block pass
      def block_argument?
        arguments? && last_argument.block_pass_type?
      end

      # Checks whether any argument of the method invocation is a splat
      # argument, i.e. `*splat`.
      #
      # @return [Boolean] whether the invoked method is a splat argument
      def splat_argument?
        arguments? && arguments.any?(&:splat_type?)
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `send` node
      def node_parts
        [*self]
      end
    end
  end
end
