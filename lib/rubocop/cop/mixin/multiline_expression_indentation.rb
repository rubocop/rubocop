# encoding: utf-8

require 'pp'

module RuboCop
  module Cop
    # Common functionality for checking multiline method calls and binary
    # operations.
    module MultilineExpressionIndentation
      def on_send(node)
        return unless relevant_node?(node)

        receiver, method_name, *_args = *node
        return unless receiver
        return if method_name == :[] # Don't check parameters inside [].

        lhs = left_hand_side(receiver)
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
        _, method_name, *args = *send_node
        if operator?(method_name) && args.any?
          args.first.source_range # not used for method calls
        else
          dot = send_node.loc.dot
          selector = send_node.loc.selector
          if dot && selector && dot.line == selector.line
            dot.join(selector)
          elsif selector
            selector
          elsif dot.line == send_node.loc.begin.line
            # lambda.(args)
            dot.join(send_node.loc.begin)
          end
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
          if offending_range(node, lhs, rhs, alternative_style)
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
          when :if, :while, :until then expression, = *a
          when :for                then _, expression, = *a
          when :return             then expression, = *a
          end

          within_node?(node, expression) if expression
        end
      end

      def argument_in_method_call(node)
        node.each_ancestor(:send).find do |a|
          _, method_name, *args = *a
          next if assignment_call?(method_name)
          args.any? { |arg| within_node?(node, arg) }
        end
      end

      def part_of_assignment_rhs(node, candidate)
        node.each_ancestor.find do |a|
          case a.type
          when :if, :while, :until, :for, :return, :array
            break # other kinds of alignment
          when :block
            break if part_of_block_body?(candidate, a)
          when :send
            _receiver, method_name, *args = *a

            # The []= operator and setters (a.b = c) are parsed as :send nodes.
            assignment_call?(method_name) &&
              (!candidate || within_node?(candidate, args.last))
          when *Util::ASGN_NODES
            !candidate || within_node?(candidate, assignment_rhs(a))
          end
        end
      end

      def assignment_call?(method_name)
        method_name == :[]= || method_name.to_s =~ /^\w.*=$/
      end

      def part_of_block_body?(candidate, node)
        _method, _args, body = *node
        body && within_node?(candidate, body)
      end

      def assignment_rhs(node)
        case node.type
        when :casgn   then _scope, _lhs, rhs = *node
        when :op_asgn then _lhs, _op, rhs = *node
        when :send    then _receiver, _method_name, *_args, rhs = *node
        else               _lhs, rhs = *node
        end
        rhs
      end

      def not_for_this_cop?(node)
        node.each_ancestor.any? do |ancestor|
          grouped_expression?(ancestor) ||
            inside_arg_list_parentheses?(node, ancestor)
        end
      end

      def grouped_expression?(node)
        node.type == :begin && node.loc.respond_to?(:begin) && node.loc.begin
      end

      def inside_arg_list_parentheses?(node, ancestor)
        a = ancestor.loc
        return false unless ancestor.type == :send && a.begin &&
                            a.begin.is?('(')
        n = node.source_range
        n.begin_pos > a.begin.begin_pos && n.end_pos < a.end.end_pos
      end
    end
  end
end
