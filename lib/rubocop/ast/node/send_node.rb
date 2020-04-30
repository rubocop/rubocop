# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      include ParameterizedNode
      include MethodDispatchNode

      def_node_matcher :attribute_accessor?, <<~PATTERN
        (send nil? ${:attr_reader :attr_writer :attr_accessor :attr} $...)
      PATTERN
    end
  end
end
