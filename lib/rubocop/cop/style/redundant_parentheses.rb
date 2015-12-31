# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant parentheses.
      #
      # @example
      #
      #   # bad
      #   (x) if ((y.z).nil?)
      #
      #   # good
      #   x if y.z.nil?
      #
      class RedundantParentheses < Cop
        include Parentheses

        ALLOWED_LITERALS = [:irange, :erange].freeze

        def_node_matcher :square_brackets?, '(send (send _recv _msg) :[] ...)'
        def_node_matcher :range_end?, '^^{irange erange}'
        def_node_matcher :method_node_and_args, '$(send _recv _msg $...)'

        def on_begin(node)
          return unless parentheses?(node)

          child_node = node.children.first
          return if keyword_ancestor?(node) && parens_required?(node)

          if keyword_with_redundant_parentheses?(child_node)
            return offense(node, 'a keyword')
          end
          return offense(node, 'a literal') if disallowed_literal?(child_node)
          return offense(node, 'a variable') if child_node.variable?
          return offense(node, 'a constant') if child_node.const_type?
          return unless method_call_with_redundant_parentheses?(child_node)

          offense(node, 'a method call')
        end

        def offense(node, msg)
          add_offense(node, :expression, "Don't use parentheses around #{msg}.")
        end

        def keyword_ancestor?(node)
          node.ancestors.first && node.ancestors.first.keyword?
        end

        def disallowed_literal?(node)
          node.literal? && !ALLOWED_LITERALS.include?(node.type)
        end

        def keyword_with_redundant_parentheses?(node)
          return false unless node.keyword?
          return true if node.special_keyword?

          args = *node

          if args.size == 1 && args.first && args.first.begin_type?
            parentheses?(args.first)
          else
            args.empty? || parentheses?(node)
          end
        end

        def method_call_with_redundant_parentheses?(node)
          return false unless node.send_type?
          return false if node.keyword_not?
          return false if range_end?(node)

          send_node, args = method_node_and_args(node)

          args.empty? || parentheses?(send_node) || square_brackets?(send_node)
        end
      end
    end
  end
end
