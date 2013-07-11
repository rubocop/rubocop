# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Common functionality for modifier cops.
      module FavorModifier
        # TODO extremely ugly solution that needs lots of polish
        def check(sexp, comments)
          case sexp.loc.keyword.source
          when 'if'     then cond, body, _else = *sexp
          when 'unless' then cond, _else, body = *sexp
          else               cond, body = *sexp
          end

          if length(sexp) > 3
            false
          else
            body_length = body_length(body)

            if body_length == 0
              false
            else
              indentation = sexp.loc.keyword.column
              kw_length = sexp.loc.keyword.size
              cond_length = cond.loc.expression.size
              space = 1
              total = indentation + body_length + space + kw_length + space +
                cond_length
              total <= LineLength.max && !body_has_comment?(body, comments)
            end
          end
        end

        def length(sexp)
          sexp.loc.expression.source.lines.to_a.size
        end

        def body_length(body)
          if body && body.loc.expression
            body.loc.expression.size
          else
            0
          end
        end

        def body_has_comment?(body, comments)
          comment_lines = comments.map(&:location).map(&:line)
          body_line = body.loc.expression.line
          comment_lines.include?(body_line)
        end
      end

      # Checks for if and unless statements that would fit on one line
      # if written as a modifier if/unless.
      class IfUnlessModifier < Cop
        include FavorModifier

        def error_message
          'Favor modifier if/unless usage when you have a single-line body. ' +
            'Another good alternative is the usage of control flow &&/||.'
        end

        def investigate(source_buffer, source, tokens, ast, comments)
          return unless ast
          on_node(:if, ast) do |node|
            # discard ternary ops, if/else and modifier if/unless nodes
            return if ternary_op?(node)
            return if modifier_if?(node)
            return if elsif?(node)
            return if if_else?(node)

            if check(node, comments)
              add_offence(:convention, node.loc.expression, error_message)
            end
          end
        end

        def ternary_op?(node)
          node.loc.respond_to?(:question)
        end

        def modifier_if?(node)
          node.loc.end.nil?
        end

        def elsif?(node)
          node.loc.keyword.is?('elsif')
        end

        def if_else?(node)
          node.loc.respond_to?(:else) && node.loc.else
        end
      end

      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until.
      class WhileUntilModifier < Cop
        include FavorModifier

        MSG =
          'Favor modifier while/until usage when you have a single-line body.'

        def investigate(source_buffer, source, tokens, ast, comments)
          return unless ast
          on_node([:while, :until], ast) do |node|
            # discard modifier while/until
            next unless node.loc.end

            if check(node, comments)
              add_offence(:convention, node.loc.expression, MSG)
            end
          end
        end
      end
    end
  end
end
