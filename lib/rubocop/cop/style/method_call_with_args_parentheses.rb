# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks presence of parentheses in method calls containing
      # parameters.
      # As in popular Ruby's frameworks a lot of methods should always be
      # called without parentheses,
      # users can ignore them by passing their names to IgnoredMethods option.
      #
      # @example
      #   # bad
      #   array.delete e
      #
      #   # good
      #   array.delete(e)
      #
      #   # good if `puts` is listed in IgnoredMethods
      #   puts 'test'
      class MethodCallWithArgsParentheses < Cop
        MSG = 'Use parentheses for method calls with arguments.'.freeze

        def on_send(node)
          return if ignored_list.include?(node.method_name)
          return unless node.arguments? && !node.parenthesized?
          return if operator_call?(node)

          add_offense(node, :selector)
        end

        def on_super(node)
          # super nodetype implies call with arguments.
          return if parentheses?(node)

          add_offense(node, :keyword)
        end

        def on_yield(node)
          args = node.children
          return if args.empty?
          return if parentheses?(node)

          add_offense(node, :keyword)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(args_begin(node), '(')
            corrector.insert_after(args_end(node), ')')
          end
        end

        private

        def ignored_list
          cop_config['IgnoredMethods'].map(&:to_sym)
        end

        def parentheses?(node)
          node.loc.begin
        end

        def operator_call?(node)
          node.operator_method?
        end

        def args_begin(node)
          loc = node.loc
          selector = node.super_type? ? loc.keyword : loc.selector
          selector.end.resize(1)
        end

        def args_end(node)
          node.loc.expression.end
        end
      end
    end
  end
end
