# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested ternary op expressions.
      #
      # @example
      #   # bad
      #   a ? (b ? b1 : b2) : a2
      #
      #   # good
      #   if a
      #     b ? b1 : b2
      #   else
      #     a2
      #   end
      class NestedTernaryOperator < Base
        extend AutoCorrector

        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` ' \
              'constructs instead.'

        def on_if(node)
          return unless node.ternary?

          node.each_descendant(:if).select(&:ternary?).each do |nested_ternary|
            add_offense(nested_ternary) do |corrector|
              if_node = if_node(nested_ternary)

              corrector.replace(if_node, <<~RUBY.chop)
                if #{if_node.condition.source}
                  #{remove_parentheses(if_node.if_branch.source)}
                else
                  #{if_node.else_branch.source}
                end
              RUBY
            end
          end
        end

        private

        def if_node(node)
          node = node.parent
          return node if node.if_type?

          if_node(node)
        end

        def remove_parentheses(source)
          return source unless source.start_with?('(')

          source.gsub(/\A\(/, '').gsub(/\)\z/, '')
        end
      end
    end
  end
end
