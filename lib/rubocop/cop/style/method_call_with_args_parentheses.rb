# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the presence (default) or absence of parentheses in
      # method calls containing parameters.
      #
      # In the default style (require_parentheses), macro methods are ignored.
      # Additional methods can be added to the `IgnoredMethods` list. This
      # option is valid only in the default style.
      #
      # In the alternative style (omit_parentheses), there are two additional
      # options.
      #
      # 1. `AllowParenthesesInChaining` is `false` by default. Setting it to
      #    `true` allows the presence of parentheses in the last call during
      #    method chaining.
      #
      # 2. `AllowParenthesesInMultilineCall` is `false` by default. Setting it
      #     to `true` allows the presence of parentheses in multi-line method
      #     calls.
      #
      # @example EnforcedStyle: require_parentheses
      #
      #
      #   # bad
      #   array.delete e
      #
      #   # good
      #   array.delete(e)
      #
      #   # good
      #   # Operators don't need parens
      #   foo == bar
      #
      #   # good
      #   # Setter methods don't need parens
      #   foo.bar = baz
      #
      #   # okay with `puts` listed in `IgnoredMethods`
      #   puts 'test'
      #
      #   # IgnoreMacros: true (default)
      #
      #   # good
      #   class Foo
      #     bar :baz
      #   end
      #
      #   # IgnoreMacros: false
      #
      #   # bad
      #   class Foo
      #     bar :baz
      #   end
      #
      # @example EnforcedStyle: omit_parentheses
      #
      #   # bad
      #   array.delete(e)
      #
      #   # good
      #   array.delete e
      #
      #   # bad
      #   foo.enforce(strict: true)
      #
      #   # good
      #   foo.enforce strict: true
      #
      #   # AllowParenthesesInMultilineCall: false (default)
      #
      #   # bad
      #   foo.enforce(
      #     strict: true
      #   )
      #
      #   # good
      #   foo.enforce \
      #     strict: true
      #
      #   # AllowParenthesesInMultilineCall: true
      #
      #   # good
      #   foo.enforce(
      #     strict: true
      #   )
      #
      #   # good
      #   foo.enforce \
      #     strict: true
      #
      #   # AllowParenthesesInChaining: false (default)
      #
      #   # bad
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      #
      #   # AllowParenthesesInChaining: true
      #
      #   # good
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      class MethodCallWithArgsParentheses < Cop
        include ConfigurableEnforcedStyle
        include IgnoredMethods

        TRAILING_WHITESPACE_REGEX = /\s+\Z/.freeze

        def on_send(node)
          case style
          when :require_parentheses
            add_offense_for_require_parentheses(node)
          when :omit_parentheses
            add_offense_for_omit_parentheses(node)
          end
        end
        alias on_super on_send
        alias on_yield on_send

        def autocorrect(node)
          case style
          when :require_parentheses
            autocorrect_for_require_parentheses(node)
          when :omit_parentheses
            autocorrect_for_omit_parentheses(node)
          end
        end

        def message(_node = nil)
          case style
          when :require_parentheses
            'Use parentheses for method calls with arguments.'.freeze
          when :omit_parentheses
            'Omit parentheses for method calls with arguments.'.freeze
          end
        end

        private

        def add_offense_for_require_parentheses(node)
          return if ignored_method?(node.method_name)
          return if eligible_for_parentheses_omission?(node)
          return unless node.arguments? && !node.parenthesized?

          add_offense(node)
        end

        def add_offense_for_omit_parentheses(node)
          return unless node.parenthesized?
          return if node.implicit_call?
          return if super_call_without_arguments?(node)
          return if camel_case_method_call_without_arguments?(node)
          return if eligible_for_parentheses_presence?(node)

          add_offense(node, location: node.loc.begin.join(node.loc.end))
        end

        def autocorrect_for_require_parentheses(node)
          lambda do |corrector|
            corrector.replace(args_begin(node), '(')

            unless args_parenthesized?(node)
              corrector.insert_after(args_end(node), ')')
            end
          end
        end

        def autocorrect_for_omit_parentheses(node)
          lambda do |corrector|
            if parentheses_at_the_end_of_multiline_call?(node)
              corrector.replace(args_begin(node), ' \\')
            else
              corrector.replace(args_begin(node), ' ')
            end
            corrector.remove(node.loc.end)
          end
        end

        def eligible_for_parentheses_omission?(node)
          node.operator_method? || node.setter_method? || ignore_macros?(node)
        end

        def ignore_macros?(node)
          cop_config['IgnoreMacros'] && node.macro?
        end

        def args_begin(node)
          loc = node.loc
          selector =
            node.super_type? || node.yield_type? ? loc.keyword : loc.selector

          resize_by = args_parenthesized?(node) ? 2 : 1
          selector.end.resize(resize_by)
        end

        def args_end(node)
          node.loc.expression.end
        end

        def args_parenthesized?(node)
          return false unless node.arguments.one?

          first_node = node.arguments.first
          first_node.begin_type? && first_node.parenthesized_call?
        end

        def parentheses_at_the_end_of_multiline_call?(node)
          node.multiline? &&
            node.loc.begin.source_line
                .gsub(TRAILING_WHITESPACE_REGEX, '')
                .end_with?('(')
        end

        def super_call_without_arguments?(node)
          node.super_type? && node.arguments.none?
        end

        def camel_case_method_call_without_arguments?(node)
          node.camel_case_method? && node.arguments.none?
        end

        def eligible_for_parentheses_presence?(node)
          call_in_literals?(node) ||
            call_with_ambiguous_arguments?(node) ||
            call_in_logical_operators?(node) ||
            allowed_multiline_call_with_parentheses?(node) ||
            allowed_chained_call_with_parentheses?(node)
        end

        def call_in_literals?(node)
          node.parent &&
            (node.parent.pair_type? ||
             node.parent.array_type? ||
             ternary_if?(node.parent))
        end

        def call_in_logical_operators?(node)
          node.parent &&
            (logical_operator?(node.parent) ||
             node.parent.descendants.any?(&method(:logical_operator?)))
        end

        def call_with_ambiguous_arguments?(node)
          call_with_braced_block?(node) ||
            call_as_argument?(node) ||
            hash_literal_in_arguments?(node) ||
            node.descendants.any? do |n|
              splat?(n) || ternary_if?(n) || logical_operator?(n)
            end
        end

        def call_with_braced_block?(node)
          node.block_node && node.block_node.braces?
        end

        def call_as_argument?(node)
          node.parent && node.parent.send_type?
        end

        def hash_literal_in_arguments?(node)
          node.arguments.any? do |n|
            hash_literal?(n) ||
              n.send_type? && node.descendants.any?(&method(:hash_literal?))
          end
        end

        def allowed_multiline_call_with_parentheses?(node)
          cop_config['AllowParenthesesInMultilineCall'] && node.multiline?
        end

        def allowed_chained_call_with_parentheses?(node)
          return unless cop_config['AllowParenthesesInChaining']

          previous = node.descendants.first
          return false unless previous && previous.send_type?

          previous.parenthesized? ||
            allowed_chained_call_with_parentheses?(previous)
        end

        def splat?(node)
          node.splat_type? || node.kwsplat_type? || node.block_pass_type?
        end

        def ternary_if?(node)
          node.if_type? && node.ternary?
        end

        def logical_operator?(node)
          (node.and_type? || node.or_type?) && node.logical_operator?
        end

        def hash_literal?(node)
          node.hash_type? && node.braces?
        end
      end
    end
  end
end
