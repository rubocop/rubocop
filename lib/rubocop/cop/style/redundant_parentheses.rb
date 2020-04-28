# frozen_string_literal: true

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

        def_node_matcher :square_brackets?,
                         '(send {(send _recv _msg) str array hash} :[] ...)'
        def_node_matcher :range_end?, '^^{irange erange}'
        def_node_matcher :method_node_and_args, '$(call _recv _msg $...)'
        def_node_matcher :rescue?, '{^resbody ^^resbody}'
        def_node_matcher :arg_in_call_with_block?,
                         '^^(block (send _ _ equal?(%0) ...) ...)'

        def on_begin(node)
          return if !parentheses?(node) || parens_allowed?(node)
          return if node.parent && (node.parent.while_post_type? ||
                                    node.parent.until_post_type?)

          check(node)
        end

        def autocorrect(node)
          ParenthesesCorrector.correct(node)
        end

        private

        def parens_allowed?(node)
          empty_parentheses?(node) ||
            first_arg_begins_with_hash_literal?(node) ||
            rescue?(node) ||
            allowed_expression?(node)
        end

        def allowed_expression?(node)
          allowed_ancestor?(node) ||
            allowed_method_call?(node) ||
            allowed_array_or_hash_element?(node) ||
            allowed_multiple_expression?(node)
        end

        def allowed_ancestor?(node)
          # Don't flag `break(1)`, etc
          keyword_ancestor?(node) && parens_required?(node)
        end

        def allowed_method_call?(node)
          # Don't flag `method (arg) { }`
          arg_in_call_with_block?(node) && !parentheses?(node.parent)
        end

        def allowed_multiple_expression?(node)
          return false if node.children.one?

          ancestor = node.ancestors.first
          return false unless ancestor

          !ancestor.begin_type? && !ancestor.def_type? && !ancestor.block_type?
        end

        def empty_parentheses?(node)
          # Don't flag `()`
          node.children.empty?
        end

        def first_arg_begins_with_hash_literal?(node)
          # Don't flag `method ({key: value})` or `method ({key: value}.method)`
          method_chain_begins_with_hash_literal?(node.children.first) &&
            first_argument?(node) &&
            !parentheses?(node.parent)
        end

        def method_chain_begins_with_hash_literal?(node)
          return false if node.nil?
          return true if node.hash_type?
          return false unless node.send_type?

          method_chain_begins_with_hash_literal?(node.children.first)
        end

        def check(begin_node)
          node = begin_node.children.first
          if keyword_with_redundant_parentheses?(node)
            return offense(begin_node, 'a keyword')
          end
          if disallowed_literal?(begin_node, node)
            return offense(begin_node, 'a literal')
          end
          return offense(begin_node, 'a variable') if node.variable?
          return offense(begin_node, 'a constant') if node.const_type?

          check_send(begin_node, node) if node.call_type?
        end

        def check_send(begin_node, node)
          return check_unary(begin_node, node) if node.unary_operation?

          return unless method_call_with_redundant_parentheses?(node)
          return if call_chain_starts_with_int?(begin_node, node)

          offense(begin_node, 'a method call')
        end

        def check_unary(begin_node, node)
          return if begin_node.chained?

          node = node.children.first while suspect_unary?(node)

          if node.send_type?
            return unless method_call_with_redundant_parentheses?(node)
          end

          offense(begin_node, 'an unary operation')
        end

        def offense(node, msg)
          add_offense(node, message: "Don't use parentheses around #{msg}.")
        end

        def suspect_unary?(node)
          node.send_type? && node.unary_operation? && !node.prefix_not?
        end

        def keyword_ancestor?(node)
          node.parent&.keyword?
        end

        def allowed_array_or_hash_element?(node)
          # Don't flag
          # ```
          # { a: (1
          #      ), }
          # ```
          (hash_element?(node) || array_element?(node)) &&
            only_closing_paren_before_comma?(node)
        end

        def hash_element?(node)
          node.parent&.pair_type?
        end

        def array_element?(node)
          node.parent&.array_type?
        end

        def only_closing_paren_before_comma?(node)
          source_buffer = node.source_range.source_buffer
          line_range = source_buffer.line_range(node.loc.end.line)

          line_range.source =~ /^\s*\)\s*,/
        end

        def disallowed_literal?(begin_node, node)
          node.literal? &&
            !node.range_type? &&
            !raised_to_power_negative_numeric?(begin_node, node)
        end

        def raised_to_power_negative_numeric?(begin_node, node)
          return false unless node.numeric_type?

          siblings = begin_node.parent&.children
          return false if siblings.nil?

          next_sibling = siblings[begin_node.sibling_index + 1]
          base_value = node.children.first

          base_value.negative? && next_sibling == :**
        end

        def keyword_with_redundant_parentheses?(node)
          return false unless node.keyword?
          return true if node.special_keyword?

          args = *node

          if only_begin_arg?(args)
            parentheses?(args.first)
          else
            args.empty? || parentheses?(node)
          end
        end

        def method_call_with_redundant_parentheses?(node)
          return false unless node.call_type?
          return false if node.prefix_not?
          return false if range_end?(node)

          send_node, args = method_node_and_args(node)

          args.empty? || parentheses?(send_node) || square_brackets?(send_node)
        end

        def only_begin_arg?(args)
          args.one? && args.first.begin_type?
        end

        def first_argument?(node)
          first_send_argument?(node) || first_super_argument?(node)
        end

        def_node_matcher :first_send_argument?, <<~PATTERN
          ^(send _ _ equal?(%0) ...)
        PATTERN

        def_node_matcher :first_super_argument?, <<~PATTERN
          ^(super equal?(%0) ...)
        PATTERN

        def call_chain_starts_with_int?(begin_node, send_node)
          recv = first_part_of_call_chain(send_node)
          recv&.int_type? && (parent = begin_node.parent) &&
            parent.send_type? && (parent.method?(:-@) || parent.method?(:+@))
        end
      end
    end
  end
end
