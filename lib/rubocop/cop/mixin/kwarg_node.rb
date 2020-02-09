# frozen_string_literal: true

module RuboCop
  module Cop
    # Common methods for checking if a token is a kwarg.
    module KwargNode
      private

      def kwarg?(token)
        node_at_pos(token.pos)&.kwarg_type?
      end

      def node_at_pos(pos)
        processed_source.ast.descendants.detect do |arg|
          arg.source_range == pos
        end
      end
    end
  end
end
