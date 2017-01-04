# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `until` nodes.
    class UntilNode < RuboCop::Node
      include ConditionalNode
      include ModifierNode

      def keyword
        'until'
      end

      def do?
        loc.begin && loc.begin.is?('do')
      end

      def node_parts
        [*self]
      end
    end
  end
end
