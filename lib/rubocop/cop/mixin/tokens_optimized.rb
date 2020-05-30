module RuboCop
  module Cop
    module TokensOptimized
      include SurroundingSpace

      def tokens(node)
        @tokens ||= {}
        return @tokens[node.object_id] if @tokens[node.object_id]

        left = index_of_first_token(node)
        right = index_of_last_token(node)
        @tokens[node.object_id] = processed_source.tokens[left..right]
        @tokens[node.object_id]
      end
    end
  end
end
