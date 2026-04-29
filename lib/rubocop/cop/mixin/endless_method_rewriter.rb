# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for rewriting endless methods to normal method definitions
    module EndlessMethodRewriter
      def correct_to_multiline(corrector, node)
        replacement = [
          "def #{receiver(node)}#{node.method_name}#{arguments(node)}",
          "#{indent(node, offset: configured_indentation_width)}#{node.body.source}",
          "#{indent(node)}end"
        ].join("\n")

        corrector.replace(node, replacement)
      end

      private

      def receiver(node)
        node.receiver ? "#{node.receiver.source}#{node.loc.operator.source}" : ''
      end

      def arguments(node, missing = '')
        node.arguments.any? ? node.arguments.source : missing
      end

      def configured_indentation_width
        cop_config['IndentationWidth'] || config.for_cop('Layout/IndentationWidth')['Width'] || 2
      end
    end
  end
end
