# frozen_string_literal: true

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

        def initialize(*)
          super
          return unless style_configured?

          case style
          when :require_parentheses
            extend RequireParentheses
          when :omit_parentheses
            extend OmitParentheses
          end
        end

        # @abstract Overridden in style modules
        def autocorrect(_node); end

        private

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
      end
    end
  end
end
