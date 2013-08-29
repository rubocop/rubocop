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
        CORRECT_INDENTATION = 2
        MSG = "Use #{CORRECT_INDENTATION} (not %d) spaces for indentation."

        def on_kwbegin(node)
          node.children.each { |c| check_indentation(node.loc.end, c) }
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

        def on_def(node)
          _method_name, _args, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_defs(node)
          _scope, _method_name, _args, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_for(node)
          _variable, _collection, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_while(node)
          _condition, body = *node
          check_indentation(node.loc.keyword, body)
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

        def on_if(node)
          return if ternary_op?(node)
          return if modifier_if?(node)

          case node.loc.keyword.source
          when 'if'     then _condition, body, else_clause = *node
          when 'unless' then _condition, else_clause, body = *node
          else               _condition, body = *node
          end

          check_if(node, body, else_clause) if body
        end

        private

        def check_if(node, body, else_clause)
          return if ternary_op?(node)
          # Don't check if expression is on same line as "then" keyword.
          check_indentation(node.loc.keyword, body)
          if else_clause
            if elsif?(else_clause)
              _condition, inner_body, inner_else_clause = *else_clause
              check_if(else_clause, inner_body, inner_else_clause)
            else
              check_indentation(node.loc.keyword, else_clause)
            end
          end
        end

        def modifier_if?(node)
          node.loc.end.nil?
        end

        def ternary_op?(node)
          node.loc.respond_to?(:question)
        end

        def elsif?(node)
          node.loc.respond_to?(:keyword) && node.loc.keyword &&
            node.loc.keyword.is?('elsif')
        end

        def check_indentation(base_loc, body_node)
          return unless body_node
          return if body_node.loc.line == base_loc.line
          # Don't check indentation if the line doesn't start with the body.
          # For example lines like "else do_something".
          first_char_pos_on_line = body_node.loc.expression.source_line =~ /\S/
          return unless body_node.loc.column == first_char_pos_on_line

          indentation = body_node.loc.column - base_loc.column
          if indentation != CORRECT_INDENTATION
            expr = body_node.loc.expression
            begin_pos, end_pos = if indentation >= 0
                                   [expr.begin_pos - indentation,
                                    expr.begin_pos]
                                 else
                                   [expr.begin_pos,
                                    expr.begin_pos - indentation]
                                 end
            convention(nil,
                       Parser::Source::Range.new(expr.source_buffer,
                                                 begin_pos, end_pos),
                       sprintf(MSG, indentation))
          end
        end
      end
    end
  end
end
