# encoding: utf-8

module Rubocop
  module Cop
    class ReduceArguments < Cop
      ERROR_MESSAGE = 'Name reduce arguments |a, e| (accumulator, element)'

      ARGS_NODE = s(:args, s(:arg, :a), s(:arg, :e))

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:block, sexp) do |node|
          block_size = node.src.end.line - node.src.begin.line

          # we care only for single line blocks
          next unless block_size == 0

          method_node, args_node, _body_node = *node
          receiver, method_name, _method_args = *method_node

          # discard other scenarios
          next unless receiver
          next unless [:reduce, :inject].include?(method_name)

          unless args_node == ARGS_NODE
            add_offence(:convention, node.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
