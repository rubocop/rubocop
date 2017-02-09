# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking multiline method calls and binary
    # operations.
    module MultilineExpressionIndentation
      def on_send(node)
        return if !node.receiver || node.method?(:[])
        return unless relevant_node?(node)

        lhs = left_hand_side(node.receiver)
        rhs = right_hand_side(node)
        range = offending_range(node, lhs, rhs, style)
        check(range, node, lhs, rhs)
      end

      # In a chain of method calls, we regard the top send node as the base
      # for indentation of all lines following the first. For example:
      # a.
      #   b c { block }.            <-- b is indented relative to a
      #   d                         <-- d is indented relative to a
      def left_hand_side(lhs)
        lhs = lhs.parent while lhs.parent && lhs.parent.send_type?
        lhs
      end

      def right_hand_side(send_node)
        if send_node.operator_method? && send_node.arguments?
          send_node.first_argument.source_range # not used for method calls
        else
          regular_method_right_hand_side(send_node)
        end
      end

      def regular_method_right_hand_side(send_node)
        dot = send_node.loc.dot
        selector = send_node.loc.selector
        if send_node.dot? && selector && dot.line == selector.line
          dot.join(selector)
        elsif selector
          selector
        elsif send_node.implicit_call?
          dot.join(send_node.loc.begin)
        end
      end

      def correct_indentation(node)
        if kw_node_with_special_indentation(node)
          # This cop could have its own IndentationWidth configuration
          configured_indentation_width +
            @config.for_cop('Style/IndentationWidth')['Width']
        else
          configured_indentation_width
        end
      end

      def check(range, node, lhs, rhs)
        if range
          incorrect_style_detected(range, node, lhs, rhs)
        else
          correct_style_detected
        end
      end

      def incorrect_style_detected(range, node, lhs, rhs)
        add_offense(range, range, message(node, lhs, rhs)) do
          if supported_styles.size > 2 ||
             offending_range(node, lhs, rhs, alternative_style)
            unrecognized_style_detected
          else
            opposite_style_detected
          end
        end
      end

      def indentation(node)
        node.source_range.source_line =~ /\S/
      end

      def operation_description(node, rhs)
        ancestor = kw_node_with_special_indentation(node)
        if ancestor
          kw = ancestor.loc.keyword.source
          kind = kw == 'for' ? 'collection' : 'condition'
          article = kw =~ /^[iu]/ ? 'an' : 'a'
          "a #{kind} in #{article} `#{kw}` statement"
        else
          'an expression' +
            (part_of_assignment_rhs(node, rhs) ? ' in an assignment' : '')
        end
      end

      def kw_node_with_special_indentation(node)
        node.each_ancestor.find do |a|
          next unless a.loc.respond_to?(:keyword)

          case a.type
          when :for                  then _, expression, = *a
          when :return               then expression, = *a
          when *Util::MODIFIER_NODES then expression, = *a
          end

          within_node?(node, expression) if expression
        end
      end

      def argument_in_method_call(node)
        node.each_ancestor(:send, :block).find do |a|
          # If the node is inside a block, it makes no difference if that block
          # is an argument in a method call. It doesn't count.
          break false if a.block_type?

          next if a.setter_method?

          a.arguments.any? { |arg| within_node?(node, arg) }
        end
      end

      def part_of_assignment_rhs(node, candidate)
        node.each_ancestor.find do |a|
          case a.type
          when :if, :while, :until, :for, :return, :array, :kwbegin
            break # other kinds of alignment
          when :block
            break if part_of_block_body?(candidate, a)
          when :send
            valid_method_rhs_candidate?(candidate, a)
          when *Util::ASGN_NODES
            valid_rhs_candidate?(candidate, assignment_rhs(a))
          end
        end
      end

      # The []= operator and setters (a.b = c) are parsed as :send nodes.
      def valid_method_rhs_candidate?(candidate, node)
        node.setter_method? &&
          valid_rhs_candidate?(candidate, node.last_argument)
      end

      def valid_rhs_candidate?(candidate, node)
        !candidate || within_node?(candidate, node)
      end

      def part_of_block_body?(candidate, node)
        _method, _args, body = *node
        body && within_node?(candidate, body)
      end

      def assignment_rhs(node)
        case node.type
        when :casgn   then _scope, _lhs, rhs = *node
        when :op_asgn then _lhs, _op, rhs = *node
        when :send    then rhs = node.last_argument
        else               _lhs, rhs = *node
        end
        rhs
      end

      def not_for_this_cop?(node)
        node.ancestors.any? do |ancestor|
          grouped_expression?(ancestor) ||
            inside_arg_list_parentheses?(node, ancestor)
        end
      end

      def grouped_expression?(node)
        node.begin_type? && node.loc.respond_to?(:begin) && node.loc.begin
      end

      def inside_arg_list_parentheses?(node, ancestor)
        return false unless ancestor.send_type? && ancestor.parenthesized?

        node.source_range.begin_pos > ancestor.loc.begin.begin_pos &&
          node.source_range.end_pos < ancestor.loc.end.end_pos
      end
    end
  end
end
