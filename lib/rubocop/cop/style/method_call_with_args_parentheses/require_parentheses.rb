# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class MethodCallWithArgsParentheses
        # Style require_parentheses
        module RequireParentheses
          REQUIRE_MSG = 'Use parentheses for method calls with arguments.'
          private_constant :REQUIRE_MSG

          private

          def require_parentheses(node)
            return if allowed_method_name?(node.method_name)
            return if matches_allowed_pattern?(node.method_name)
            return if eligible_for_parentheses_omission?(node)
            return unless node.arguments? && !node.parenthesized?

            add_offense(node, message: REQUIRE_MSG) do |corrector|
              corrector.replace(args_begin(node), '(')

              corrector.insert_after(args_end(node), ')') unless args_parenthesized?(node)
            end
          end

          def allowed_method_name?(name)
            allowed_method?(name) || matches_allowed_pattern?(name)
          end

          def eligible_for_parentheses_omission?(node)
            return true if do_end_block_in_command_arguments?(node)

            node.operator_method? || node.setter_method? || ignored_macro?(node)
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

          def included_macros_list
            @included_macros_list ||= cop_config.fetch('IncludedMacros', []).map(&:to_sym).freeze
          end

          def included_macro_patterns
            @included_macro_patterns ||=
              cop_config.fetch('IncludedMacroPatterns', [])
                        .map { |pattern| Regexp.new(pattern) }.freeze
          end

          def matches_included_macro_pattern?(method_name)
            included_macro_patterns.any? do |pattern|
              pattern.match?(method_name.to_s)
            end
          end

          def ignored_macro?(node)
            cop_config['IgnoreMacros'] &&
              node.macro? &&
              !included_macros_list.include?(node.method_name) &&
              !matches_included_macro_pattern?(node.method_name)
          end
        end
      end
    end
  end
end
