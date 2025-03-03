# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for rewriting endless methods to normal method definitions
    module EndlessMethodRewriter
      def correct_to_multiline(corrector, node)
        replacement = <<~RUBY.strip
          def #{method_name(node)}#{arguments(node)}
            #{node.body.source}
          end
        RUBY

        corrector.replace(node, replacement)
      end

      private

      def method_name(node)
        if node.receiver
          "#{node.receiver.source}.#{node.method_name}"
        else
          node.method_name
        end
      end

      def arguments(node, missing = '')
        node.arguments.any? ? node.arguments.source : missing
      end
    end
  end
end
