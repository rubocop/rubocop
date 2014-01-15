# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for indentation that doesn't use two spaces.
      #
      # @example
      #
      # class A
      #  def test
      #   puts 'hello'
      #  end
      # end
      class IndentationWidth < Cop
        include CheckMethods
        include CheckAssignment
        include IfNode

        CORRECT_INDENTATION = 2

        def on_kwbegin(node)
          check_indentation(node.loc.end, node.children.first)
        end

        def on_block(node)
          _method, _args, body = *node
          # Check body against end/} indentation. Checking against variable
          # assignments, etc, would be more difficult.
          check_indentation(node.loc.end, body)
        end

        def on_module(node)
          _module_name, *members = *node
          members.each { |m| check_indentation(node.loc.keyword, m) }
        end

        def on_class(node)
          _class_name, _base_class, *members = *node
          members.each { |m| check_indentation(node.loc.keyword, m) }
        end

        def check(node, _method_name, _args, body)
          check_indentation(node.loc.keyword, body)
        end

        def on_for(node)
          _variable, _collection, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_while(node)
          _condition, body = *node
          if node.loc.keyword.begin_pos == node.loc.expression.begin_pos
            check_indentation(node.loc.keyword, body)
          end
        end

        alias_method :on_until, :on_while

        def on_case(node)
          _condition, *branches = *node
          latest_when = nil
          branches.compact.each do |b|
            if b.type == :when
              _condition, body = *b
              # Check "when" body against "when" keyword indentation.
              check_indentation(b.loc.keyword, body)
              latest_when = b
            else
              # Since it's not easy to get the position of the "else" keyword,
              # we check "else" body against latest "when" keyword indentation.
              check_indentation(latest_when.loc.keyword, b)
            end
          end
        end

        def on_if(node, offset = 0)
          return if ignored_node?(node)
          return if ternary_op?(node)
          return if modifier_if?(node)

          case node.loc.keyword.source
          when 'if'     then _condition, body, else_clause = *node
          when 'unless' then _condition, else_clause, body = *node
          else               _condition, body = *node
          end

          check_if(node, body, else_clause, offset) if body
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check its indentation.
          rhs = first_part_of_call_chain(rhs)

          if rhs && rhs.type == :if
            on_if(rhs, rhs.loc.column - node.loc.column)
            ignore_node(rhs)
          end
        end

        def check_if(node, body, else_clause, offset)
          return if ternary_op?(node)
          # Don't check if expression is on same line as "then" keyword.
          check_indentation(node.loc.keyword, body, offset)
          if else_clause
            if elsif?(else_clause)
              _condition, inner_body, inner_else_clause = *else_clause
              check_if(else_clause, inner_body, inner_else_clause, offset)
            else
              check_indentation(node.loc.else, else_clause)
            end
          end
        end

        def check_indentation(base_loc, body_node, offset = 0)
          return unless body_node
          return if body_node.loc.line == base_loc.line
          return if starts_with_access_modifier?(body_node)

          # Don't check indentation if the line doesn't start with the body.
          # For example lines like "else do_something".
          first_char_pos_on_line = body_node.loc.expression.source_line =~ /\S/
          return unless body_node.loc.column == first_char_pos_on_line

          indentation = body_node.loc.column - base_loc.column
          return if indentation == CORRECT_INDENTATION ||
              indentation + offset == CORRECT_INDENTATION

          expr = body_node.loc.expression
          begin_pos, end_pos =
            if indentation >= 0
              [expr.begin_pos - indentation, expr.begin_pos]
            else
              [expr.begin_pos, expr.begin_pos - indentation]
            end

          add_offence(nil,
                      Parser::Source::Range.new(expr.source_buffer,
                                                begin_pos, end_pos),
                      sprintf("Use #{CORRECT_INDENTATION} (not %d) spaces " +
                              'for indentation.', indentation))
        end

        def starts_with_access_modifier?(body_node)
          body_node.type == :begin &&
            AccessModifierIndentation.modifier_node?(body_node.children.first)
        end
      end
    end
  end
end
