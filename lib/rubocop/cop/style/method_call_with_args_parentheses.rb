# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks presence of parentheses in method calls containing
      # parameters. By default, macro methods are ignored. Additional methods
      # can be added to the `IgnoredMethods` list.
      #
      # @example
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
      class MethodCallWithArgsParentheses < Cop
        MSG = 'Use parentheses for method calls with arguments.'.freeze

        def on_send(node)
          return if ignored_method?(node)
          return unless node.arguments? && !node.parenthesized?

          add_offense(node)
        end
        alias on_super on_send
        alias on_yield on_send

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(args_begin(node), '(')

            unless args_parenthesized?(node)
              corrector.insert_after(args_end(node), ')')
            end
          end
        end

        private

        def ignored_method?(node)
          node.operator_method? || node.setter_method? ||
            ignore_macros? && node.macro? ||
            ignored_list.include?(node.method_name)
        end

        def ignored_list
          cop_config['IgnoredMethods'].map(&:to_sym)
        end

        def ignore_macros?
          cop_config['IgnoreMacros']
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

          node.arguments.first.parenthesized_call?
        end
      end
    end
  end
end
