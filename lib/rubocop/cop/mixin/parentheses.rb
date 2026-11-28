# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling parentheses.
    module Parentheses
      private

      def parens_required?(node)
        range  = node.source_range
        source = range.source_buffer.source
        /[a-z]/.match?(source[range.begin_pos - 1]) || /[a-z]/.match?(source[range.end_pos])
      end

      def do_end_block_in_command_arguments?(node)
        return false unless node.block_node&.keywords?

        child = node.block_node
        child.each_ancestor do |ancestor|
          return !ancestor.parenthesized? if command_argument?(ancestor, child)
          return false if command_arguments_boundary?(ancestor, child)

          child = ancestor
        end

        false
      end

      def command_argument?(node, child)
        return false unless node.type?(:call, :super, :yield)
        return false if node.operator_method? || node.setter_method?

        node.arguments.any? { |argument| argument.equal?(child) }
      end

      def command_arguments_boundary?(node, child)
        return true if node.type?(:any_block, :any_def, :class, :module, :sclass, :kwbegin)
        return true if node.type?(:break, :next, :return) || index_argument?(node, child)

        node.type?(:begin, :array, :hash) && node.loc?(:begin)
      end

      def index_argument?(node, child)
        return false unless node.call_type?
        return node.arguments.any? { |argument| argument.equal?(child) } if node.method?(:[])
        return false unless node.method?(:[]=)

        node.arguments[0...-1].any? { |argument| argument.equal?(child) }
      end
    end
  end
end
