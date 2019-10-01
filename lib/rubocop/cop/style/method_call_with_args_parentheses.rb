# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module RuboCop
  module Cop
    module Style
      # This cop enforces the presence (default) or absence of parentheses in
      # method calls containing parameters.
      #
      # In the default style (require_parentheses), macro methods are ignored.
      # Additional methods can be added to the `IgnoredMethods`
      # or `IgnoredPatterns` list. These options are
      # valid only in the default style. Macros can be included by
      # either setting `IgnoreMacros` to false or adding specific macros to
      # the `IncludedMacros` list.
      #
      # Precedence of options is all follows:
      #
      # 1. `IgnoredMethods`
      # 2. `IgnoredPatterns`
      # 3. `IncludedMacros`
      #
      # eg. If a method is listed in both
      # `IncludedMacros` and `IgnoredMethods`, then the latter takes
      # precedence (that is, the method is ignored).
      #
      # In the alternative style (omit_parentheses), there are three additional
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
      # 3. `AllowParenthesesInCamelCaseMethod` is `false` by default. This
      #     allows the presence of parentheses when calling a method whose name
      #     begins with a capital letter and which has no arguments. Setting it
      #     to `true` allows the presence of parentheses in such a method call
      #     even with arguments.
      #
      # @example EnforcedStyle: require_parentheses (default)
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
      #   # okay with `^assert` listed in `IgnoredPatterns`
      #   assert_equal 'test', x
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
      # @example IgnoreMacros: true (default)
      #
      #   # good
      #   class Foo
      #     bar :baz
      #   end
      #
      # @example IgnoreMacros: false
      #
      #   # bad
      #   class Foo
      #     bar :baz
      #   end
      #
      # @example AllowParenthesesInMultilineCall: false (default)
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
      # @example AllowParenthesesInMultilineCall: true
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
      # @example AllowParenthesesInChaining: false (default)
      #
      #   # bad
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      #
      # @example AllowParenthesesInChaining: true
      #
      #   # good
      #   foo().bar(1)
      #
      #   # good
      #   foo().bar 1
      #
      # @example AllowParenthesesInCamelCaseMethod: false (default)
      #
      #   # bad
      #   Array(1)
      #
      #   # good
      #   Array 1
      #
      # @example AllowParenthesesInCamelCaseMethod: true
      #
      #   # good
      #   Array(1)
      #
      #   # good
      #   Array 1
      class MethodCallWithArgsParentheses < Cop
        include ConfigurableEnforcedStyle
        include IgnoredMethods
        include IgnoredPattern

        TRAILING_WHITESPACE_REGEX = /\s+\Z/.freeze

        def on_send(node)
          case style
          when :require_parentheses
            add_offense_for_require_parentheses(node)
          when :omit_parentheses
            add_offense_for_omit_parentheses(node)
          end
        end
        alias on_csend on_send
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
            'Use parentheses for method calls with arguments.'
          when :omit_parentheses
            'Omit parentheses for method calls with arguments.'
          end
        end

        private

        def add_offense_for_require_parentheses(node)
          return if ignored_method?(node.method_name)
          return if matches_ignored_pattern?(node.method_name)
          return if eligible_for_parentheses_omission?(node)
          return unless node.arguments? && !node.parenthesized?

          add_offense(node)
        end

        def add_offense_for_omit_parentheses(node)
          return unless node.parenthesized?
          return if node.implicit_call?
          return if super_call_without_arguments?(node)
          return if allowed_camel_case_method_call?(node)
          return if legitimate_call_with_parentheses?(node)

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
          node.operator_method? || node.setter_method? || ignored_macro?(node)
        end

        def included_macros_list
          cop_config.fetch('IncludedMacros', []).map(&:to_sym)
        end

        def ignored_macro?(node)
          cop_config['IgnoreMacros'] &&
            node.macro? &&
            !included_macros_list.include?(node.method_name)
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

        def allowed_camel_case_method_call?(node)
          node.camel_case_method? &&
            (node.arguments.none? ||
             cop_config['AllowParenthesesInCamelCaseMethod'])
        end

        def legitimate_call_with_parentheses?(node)
          call_in_literals?(node) ||
            call_with_ambiguous_arguments?(node) ||
            call_in_logical_operators?(node) ||
            call_in_optional_arguments?(node) ||
            allowed_multiline_call_with_parentheses?(node) ||
            allowed_chained_call_with_parentheses?(node)
        end

        def call_in_literals?(node)
          node.parent &&
            (node.parent.pair_type? ||
             node.parent.array_type? ||
             node.parent.range_type? ||
             splat?(node.parent) ||
             ternary_if?(node.parent))
        end

        def call_in_logical_operators?(node)
          node.parent &&
            (logical_operator?(node.parent) ||
             node.parent.send_type? &&
             node.parent.arguments.any?(&method(:logical_operator?)))
        end

        def call_in_optional_arguments?(node)
          node.parent &&
            (node.parent.optarg_type? || node.parent.kwoptarg_type?)
        end

        def call_with_ambiguous_arguments?(node)
          call_with_braced_block?(node) ||
            call_as_argument_or_chain?(node) ||
            hash_literal_in_arguments?(node) ||
            node.descendants.any? do |n|
              ambigious_literal?(n) || logical_operator?(n) ||
                call_with_braced_block?(n)
            end
        end

        def call_with_braced_block?(node)
          (node.send_type? || node.super_type?) &&
            node.block_node && node.block_node.braces?
        end

        def call_as_argument_or_chain?(node)
          node.parent &&
            (node.parent.send_type? && !assigned_before?(node.parent, node) ||
             node.parent.csend_type? || node.parent.super_type?)
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
          return false unless cop_config['AllowParenthesesInChaining']

          previous = node.descendants.first
          return false unless previous&.send_type?

          previous.parenthesized? ||
            allowed_chained_call_with_parentheses?(previous)
        end

        def ambigious_literal?(node)
          splat?(node) || ternary_if?(node) || regexp_slash_literal?(node) ||
            unary_literal?(node)
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

        def regexp_slash_literal?(node)
          node.regexp_type? && node.loc.begin.source == '/'
        end

        def unary_literal?(node)
          node.numeric_type? && node.sign? ||
            node.parent&.send_type? && node.parent&.unary_operation?
        end

        def assigned_before?(node, target)
          node.assignment? &&
            node.loc.operator.begin < target.loc.begin
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
