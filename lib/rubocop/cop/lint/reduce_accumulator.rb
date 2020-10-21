# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Looks for `reduce` or `inject` blocks where the value returned (implicitly or
      # explicitly) does not include the accumulator. A block is considered valid as
      # long as at least one return value includes the accumulator.
      #
      # If the accumulator is not included in the return value, then the entire
      # block will just return a transformation of the last element value, and
      # could be rewritten as such without a loop.
      #
      # Also catches instances where an index of the accumulator is returned, as
      # this may change the type of object being retained.
      #
      # NOTE: For the purpose of reducing false positives, this cop only flags
      # returns in `reduce` blocks where the element is the only variable in
      # the expression (since we will not be able to tell what other variables
      # relate to via static analysis).
      #
      # @example
      #
      #   # bad
      #   (1..4).reduce(0) do |acc, el|
      #     el * 2
      #   end
      #
      #   # bad, may raise a NoMethodError after the first iteration
      #   %w(a b c).reduce({}) do |acc, letter|
      #     acc[letter] = true
      #   end
      #
      #   # good
      #   (1..4).reduce(0) do |acc, el|
      #     acc + el * 2
      #   end
      #
      #   # good, returns the accumulator instead of the index
      #   %w(a b c).reduce({}) do |acc, letter|
      #     acc[letter] = true
      #     acc
      #   end
      #
      #   # good, at least one branch returns the accumulator
      #   values.reduce(nil) do |result, value|
      #     break result if something?
      #     value
      #   end
      #
      #   # ignored as the return value cannot be determined
      #   enum.reduce do |acc, el|
      #     x + y
      #   end
      class UnmodifiedReduceAccumulator < Base
        MSG = 'Ensure the accumulator `%<accum>s` will be modified by `%<method>s`.'
        MSG_INDEX = 'Do not return an element of the accumulator in `%<method>s`.'

        def_node_matcher :reduce_with_block?, <<~PATTERN
          (block (send _recv {:reduce :inject} !sym) ...)
        PATTERN

        def_node_matcher :accumulator_index?, <<~PATTERN
          (send (lvar %1) {:[] :[]=} ...)
        PATTERN

        def_node_matcher :lvar_used?, <<~PATTERN
          {
            (lvar %1)
            (lvasgn %1 ...)
            (send (lvar %1) :<< ...)
            (dstr (begin (lvar %1)))
            (%RuboCop::AST::Node::SHORTHAND_ASSIGNMENTS (lvasgn %1))
          }
        PATTERN

        def_node_search :expression_values, <<~PATTERN
          `{
            (%RuboCop::AST::Node::VARIABLES $_)
            (%RuboCop::AST::Node::EQUALS_ASSIGNMENTS $_ ...)
            (send (%RuboCop::AST::Node::VARIABLES $_) :<< ...)
            (send nil? $_)
            (dstr (begin {(send nil? $_) (%RuboCop::AST::Node::VARIABLES $_)}))
            (%RuboCop::AST::Node::SHORTHAND_ASSIGNMENTS (%RuboCop::AST::Node::EQUALS_ASSIGNMENTS $_) ...)
          }
        PATTERN

        def on_block(node)
          return unless reduce_with_block?(node)

          check_return_values(node)
        end

        private

        # Return values in a block are either the value given to next,
        # the last line of a multiline block, or the only line of the block
        def return_values(block_body_node)
          nodes = [block_body_node.begin_type? ? block_body_node.child_nodes.last : block_body_node]

          block_body_node.each_descendant(:next, :break) do |n|
            # Ignore `next`/`break` inside an inner block
            next if n.each_ancestor(:block).first != block_body_node.parent
            next unless n.first_argument

            nodes << n.first_argument
          end

          nodes
        end

        def check_return_values(block_node)
          return_values = return_values(block_node.body)
          accumulator_name = block_arg_name(block_node, 0)
          element_name = block_arg_name(block_node, 1)
          message_opts = { method: block_node.method_name, accum: accumulator_name }

          if (node = returned_accumulator_index(return_values, accumulator_name))
            add_offense(node, message: format(MSG_INDEX, message_opts))
          elsif !returns_accumulator_anywhere?(return_values, accumulator_name)
            return_values.each do |return_val|
              unless acceptable_return?(return_val, element_name)
                add_offense(return_val, message: format(MSG, message_opts))
              end
            end
          end
        end

        def block_arg_name(node, index)
          node.arguments[index].node_parts[0]
        end

        # Look for an index of the accumulator being returned
        # This is always an offense, in order to try to catch potential exceptions
        # due to type mismatches
        def returned_accumulator_index(return_values, accumulator_name)
          return_values.detect { |val| accumulator_index?(val, accumulator_name) }
        end

        # If the accumulator is used in any return value, the node is acceptable since
        # the accumulator has a chance to change each iteration
        def returns_accumulator_anywhere?(return_values, accumulator_name)
          return_values.any? { |node| lvar_used?(node, accumulator_name) }
        end

        # Determine if a return value is acceptable for the purposes of this cop
        # If it is an expression containing the accumulator, it is acceptable
        # Otherwise, it is only unacceptable if it contains the iterated element, since we
        # otherwise do not have enough information to prevent false positives.
        def acceptable_return?(return_val, element_name)
          vars = expression_values(return_val).uniq
          return true if vars.none? || (vars - [element_name]).any?

          false
        end

        # Exclude `begin` nodes inside a `dstr` from being collected by `return_values`
        def allowed_type?(parent_node)
          !parent_node.dstr_type?
        end
      end
    end
  end
end
