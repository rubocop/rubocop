# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that operators have space around them, except for **
      # which should not have surrounding space.
      class SpaceAroundOperators < Cop
        include PrecedingFollowingAlignment

        def on_pair(node)
          return unless node.hash_rocket?

          return if hash_table_style? && !node.parent.pairs_on_same_line?

          check_operator(node.loc.operator, node.source_range)
        end

        def on_if(node)
          return unless node.ternary?

          check_operator(node.loc.question, node.if_branch.source_range)
          check_operator(node.loc.colon, node.else_branch.source_range)
        end

        def on_resbody(node)
          return unless node.loc.assoc
          _, variable, = *node

          check_operator(node.loc.assoc, variable.source_range)
        end

        def on_send(node)
          if node.loc.operator # aref assignment, attribute assignment
            on_special_asgn(node)
          elsif !node.unary_operation? && !called_with_dot?(node)
            op = node.method_name
            if operator_with_regular_syntax?(op)
              _, _, right, = *node
              check_operator(node.loc.selector, right.source_range)
            end
          end
        end

        def on_binary(node)
          _, right, = *node
          return if right.nil?
          check_operator(node.loc.operator, right.source_range)
        end

        def on_special_asgn(node)
          return unless node.loc.operator
          _, _, right, = *node
          check_operator(node.loc.operator, right.source_range)
        end

        alias on_or       on_binary
        alias on_and      on_binary
        alias on_lvasgn   on_binary
        alias on_masgn    on_binary
        alias on_casgn    on_special_asgn
        alias on_ivasgn   on_binary
        alias on_cvasgn   on_binary
        alias on_gvasgn   on_binary
        alias on_class    on_binary
        alias on_or_asgn  on_binary
        alias on_and_asgn on_binary
        alias on_op_asgn  on_special_asgn

        private

        def called_with_dot?(node)
          node.loc.dot
        end

        def operator_with_regular_syntax?(op)
          ![:[], :!, :[]=].include?(op) && operator?(op)
        end

        def check_operator(op, right_operand)
          with_space = range_with_surrounding_space(op)
          return if with_space.source.start_with?("\n")

          offense(op, with_space, right_operand) do |msg|
            add_offense(with_space, op, msg)
          end
        end

        def offense(op, with_space, right_operand)
          msg = offense_message(op, with_space, right_operand)
          yield msg if msg
        end

        def offense_message(op, with_space, right_operand)
          if op.is?('**')
            'Space around operator `**` detected.' unless with_space.is?('**')
          elsif with_space.source !~ /^\s.*\s$/
            "Surrounding space missing for operator `#{op.source}`."
          elsif excess_leading_space?(op, with_space) ||
                excess_trailing_space?(right_operand, with_space)
            "Operator `#{op.source}` should be surrounded by a single space."
          end
        end

        def excess_leading_space?(op, with_space)
          with_space.source =~ /^  / &&
            (!allow_for_alignment? || !aligned_with_operator?(op))
        end

        def excess_trailing_space?(right_operand, with_space)
          with_space.source =~ /  $/ &&
            (!allow_for_alignment? || !aligned_with_something?(right_operand))
        end

        def autocorrect(range)
          lambda do |corrector|
            if range.source =~ /\*\*/
              corrector.replace(range, '**')
            elsif range.source.end_with?("\n")
              corrector.replace(range, " #{range.source.strip}\n")
            else
              corrector.replace(range, " #{range.source.strip} ")
            end
          end
        end

        def align_hash_cop_config
          config.for_cop('Style/AlignHash')
        end

        def hash_table_style?
          align_hash_cop_config &&
            align_hash_cop_config['EnforcedHashRocketStyle'] == 'table'
        end
      end
    end
  end
end
