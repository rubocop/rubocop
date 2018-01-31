# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `ivar` nodes. This will be used in place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `ivar` nodes within RuboCop.
    class InstanceVariableNode < Node
      include BasicLiteralNode

      # @return Symbol symbol of the instance variable, e.g. :@foo
      def identifier
        node_parts[0]
      end

      # @return String the name of the instance variable, e.g. "foo"
      def name
        identifier.to_s[1..-1]
      end

      def node_parts
        to_a
      end
    end
  end
end
