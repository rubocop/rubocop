# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking whether a method body can become the
    # body of an endless method definition without changing its meaning.
    module EndlessMethodBodyHelp
      STATEMENT_BODY_PARENT_TYPES = %i[
        resbody when in_pattern while until for class module sclass any_block
      ].freeze

      private

      def endless_method_body?(body)
        return false if body.type?(:begin, :kwbegin, :rescue, :ensure, :masgn)
        return false if low_precedence_body?(body)
        return false if ends_with_omitted_hash_value?(body) || ends_with_anonymous_argument?(body)
        return false if body.assignment? && multiple_values?(assigned_value(body))

        !command_disallowed_in_endless_body?(body)
      end

      # `def foo = bar and baz` parses as `(def foo = bar) and baz`.
      def low_precedence_body?(body)
        body.type?(:any_match_pattern, :while_post, :until_post) ||
          (body.type?(:and, :or) && body.semantic_operator?) ||
          (body.type?(:if, :while, :until) && body.modifier_form?)
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
        return true if body_disallowed_outside_statement?(body)
        return true if negated_command_call?(body)

        body.each_node(:any_block).any? do |block|
          block.keywords? && command_call?(block.send_node)
        end
      end

      def body_disallowed_outside_statement?(body)
        return true if endless_method_with_command_body?(body)

        command_body_outside_statement?(body) || do_end_block_body_in_command_argument?(body)
      end

      def endless_method_with_command_body?(node)
        node.any_def_type? && node.endless? && command_call?(node.body)
      end

      def command_body_outside_statement?(body)
        return false unless command_call?(body)
        return false if command_position?(body.parent)

        call = argument_receiving_call(body.parent)
        return true if call.nil?

        target_ruby_version < 4.0 || !call.arguments.one?
      end

      def command_position?(def_node)
        parent = def_node.parent
        return true if parent.nil? || parent.type?(:begin, :kwbegin, :rescue, :ensure)
        return false if parent.masgn_type?
        return true if parent.assignment?
        return parent.last_argument.equal?(def_node) if setter_call?(parent)

        statement_body?(def_node, parent)
      end

      def setter_call?(node)
        node.call_type? && node.assignment_method?
      end

      def statement_body?(def_node, parent)
        return def_node.equal?(parent.body) if parent.type?(*STATEMENT_BODY_PARENT_TYPES)

        case parent.type
        when :if
          !parent.ternary? && !def_node.equal?(parent.condition)
        when :case, :case_match
          def_node.equal?(parent.else_branch)
        else
          false
        end
      end

      def argument_receiving_call(def_node)
        call = def_node.parent
        return unless call&.call_type?

        call if call.arguments.any? { |argument| argument.equal?(def_node) }
      end

      def do_end_block_body_in_command_argument?(body)
        call = argument_receiving_call(body.parent)
        return false if call.nil? || call.parenthesized?

        body.each_node(:any_block).any? do |block|
          block.keywords? && !block.send_node.lambda_literal?
        end
      end

      def assigned_value(node)
        while node.assignment? || node.rescue_type?
          node = node.rescue_type? ? node.body : node.children.last
        end
        node
      end

      # `return foo` is a command too, even as `return(foo)`.
      def command_call?(node)
        node = node.send_node if node.any_block_type?
        return node.arguments? if node.return_type?
        return false unless node.type?(:call, :super, :yield)

        node.arguments? && !node.parenthesized? && !node.operator_method? && !node.setter_method?
      end

      def negated_command_call?(node)
        node.send_type? && node.prefix_bang? && command_call?(node.receiver)
      end
    end
  end
end
