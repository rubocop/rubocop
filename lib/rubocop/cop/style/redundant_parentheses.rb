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
        ALLOWED_LITERALS = [:irange, :erange].freeze

        def_node_matcher :method_call?, '(send _recv _msg ...)'
        def_node_matcher :square_brackets?, '(send (send _recv _msg) :[] ...)'
        def_node_matcher :range_end?, '^^{irange erange}'
        def_node_matcher :method_node_and_args, '$(send _recv _msg $...)'

        def on_begin(node)
          return unless parentheses?(node)

          child_node = node.children.first
          return offense(node, 'a literal') if disallowed_literal?(child_node)
          return offense(node, 'a variable') if child_node.variable?
          return offense(node, 'a constant') if child_node.const_type?
          return unless method_call_with_redundant_parentheses?(child_node)

          offense(node, 'a method call')
        end

        def offense(node, msg)
          add_offense(node, :expression, "Don't use parentheses around #{msg}.")
        end

        def parentheses?(node)
          node.loc.begin && node.loc.begin.is?('('.freeze)
        end

        def disallowed_literal?(node)
          node.literal? && !ALLOWED_LITERALS.include?(node.type)
        end

        def method_call_with_redundant_parentheses?(node)
          return false unless method_call?(node)
          return false if range_end?(node)

          send_node, args = method_node_and_args(node)

          send_node.loc.begin || args.empty? || square_brackets?(send_node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
