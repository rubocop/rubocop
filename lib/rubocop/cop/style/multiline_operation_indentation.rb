# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of the right hand side operand in
      # binary operations that span more than one line.
      #
      # @example
      #   # bad
      #   if a +
      #   b
      #     something
      #   end
      class MultilineOperationIndentation < Cop # rubocop:disable ClassLength
        include ConfigurableEnforcedStyle
        include AutocorrectAlignment

        def on_and(node)
          check_and_or(node)
        end

        def on_or(node)
          check_and_or(node)
        end

        def on_send(node)
          receiver, method_name, *_args = *node
          return unless receiver
          return if method_name == :[] # Don't check parameters inside [].

          lhs = left_hand_side(receiver)
          rhs = right_hand_side(node)
          range = offending_range(node, lhs, rhs, style)
          check(range, node, lhs, rhs)
        end

        private

        def check_and_or(node)
          lhs, rhs = *node
          range = offending_range(node, lhs, rhs.loc.expression, style)
          check(range, node, lhs, rhs.loc.expression)
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

        def offending_range(node, lhs, rhs, given_style)
          return false unless begins_its_line?(rhs)
          return false if lhs.loc.line == rhs.line # Needed for unary op.
          return false if not_for_this_cop?(node)

          correct_column = if should_align?(node, given_style)
                             lhs.loc.column
                           else
                             indentation(lhs) + correct_indentation(node)
                           end
          @column_delta = correct_column - rhs.column
          rhs if @column_delta != 0
        end

        def message(node, lhs, rhs)
          what = operation_description(node)
          if should_align?(node, style)
            "Align the operands of #{what} spanning multiple lines."
          else
            used_indentation = rhs.column - indentation(lhs)
            "Use #{correct_indentation(node)} (not #{used_indentation}) " \
              "spaces for indenting #{what} spanning multiple lines."
          end
        end

        def indentation(node)
          node.loc.expression.source_line =~ /\S/
        end

        def operation_description(node)
          ancestor = kw_node_with_special_indentation(node)
          if ancestor
            kw = ancestor.loc.keyword.source
            kind = kw == 'for' ? 'collection' : 'condition'
            article = kw =~ /^[iu]/ ? 'an' : 'a'
            "a #{kind} in #{article} `#{kw}` statement"
          else
            'an expression' + (assignment?(node) ? ' in an assignment' : '')
          end
        end

        # In a chain of method calls, we regard the top send node as the base
        # for indentation of all lines following the first. For example:
        # a.
        #   b c { block }.            <-- b is indented relative to a
        #   d                         <-- d is indented relative to a
        def left_hand_side(receiver)
          lhs = receiver
          while lhs.parent && lhs.parent.type == :send
            _receiver, method_name, *_args = *lhs.parent
            break if operator?(method_name)
            lhs = lhs.parent
          end
          lhs
        end

        def right_hand_side(send_node)
          _, method_name, *args = *send_node
          if operator?(method_name) && args.any?
            args.first.loc.expression
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
          multiplier = kw_node_with_special_indentation(node) ? 2 : 1
          configured_indentation_width * multiplier
        end

        def should_align?(node, given_style)
          given_style == :aligned && (kw_node_with_special_indentation(node) ||
                                      assignment?(node))
        end

        def kw_node_with_special_indentation(node)
          node.each_ancestor.find do |a|
            next unless a.loc.respond_to?(:keyword)

            case a.type
            when :if, :while, :until then condition, = *a
            when :for                then _, collection, = *a
            end

            if condition || collection
              within_node?(node, condition || collection)
            end
          end
        end

        def assignment?(node)
          node.each_ancestor.find do |a|
            case a.type
            when :send
              _receiver, method_name, *_args = *a
              # The []= operator is the only assignment operator that is parsed
              # as a :send node.
              method_name == :[]=
            when *ASGN_NODES
              true
            end
          end
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
          n = node.loc.expression
          n.begin_pos > a.begin.begin_pos && n.end_pos < a.end.end_pos
        end
      end
    end
  end
end
