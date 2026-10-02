# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking whether a method body can become the
    # body of an endless method definition without changing its meaning.
    module EndlessMethodBodyHelp
      private

      def endless_method_body?(body)
        return false if body.type?(:begin, :kwbegin, :rescue, :ensure, :masgn)
        return false if ends_with_omitted_hash_value?(body) || ends_with_anonymous_argument?(body)
        return false if body.assignment? && multiple_values?(assigned_value(body))

        !command_disallowed_in_endless_body?(body)
      end

      # `foo = 1, 2` and `foo = *bar` assign an array without brackets.
      def multiple_values?(node)
        node.array_type? && !node.bracketed?
      end

      def ends_with_omitted_hash_value?(body)
        body.each_descendant(:pair).any? do |pair|
          pair.value_omission? && pair.source_range.end_pos == body.source_range.end_pos
        end
      end

      def ends_with_anonymous_argument?(body)
        forwarding = %i[forwarded_restarg forwarded_kwrestarg block_pass]

        body.each_descendant(*forwarding).any? do |argument|
          argument.source_range.end_pos == body.source_range.end_pos &&
            (!argument.block_pass_type? || argument.children.first.nil?)
        end
      end

      def command_disallowed_in_endless_body?(body)
        return true if body.assignment? && command_call?(assigned_value(body))

        body.each_node(:any_block).any? do |block|
          block.keywords? && command_call?(block.send_node)
        end
      end

      def assigned_value(node)
        while node.assignment? || node.rescue_type?
          node = node.rescue_type? ? node.body : node.children.last
        end
        node
      end

      def command_call?(node)
        node = node.send_node if node.any_block_type?
        return false unless node.type?(:call, :super, :yield)

        node.arguments? && !node.parenthesized? && !node.operator_method? && !node.setter_method?
      end
    end
  end
end
