# encoding: utf-8

module Rubocop
  module Cop
    module FavorModifier
      # TODO extremely ugly solution that needs lots of polish
      def check(sexp)
        # discard if/then/else
        return false if sexp.loc.respond_to?(:else) && sexp.loc.else

        if %w(if while).include?(sexp.loc.keyword.source)
          cond, body = *sexp
        else
          cond, _else, body = *sexp
        end

        if length(sexp) > 3
          false
        else
          cond_length = sexp.loc.keyword.size + cond.loc.expression.size + 1
          body_length = body_length(body)

          (cond_length + body_length) <= LineLength.max
        end
      end

      def length(sexp)
        sexp.loc.expression.source.split("\n").size
      end

      def body_length(body)
        if body
          body.loc.expression.column + body.loc.expression.size
        else
          0
        end
      end
    end

    class IfUnlessModifier < Cop
      include FavorModifier

      def error_message
        'Favor modifier if/unless usage when you have a single-line body. ' +
          'Another good alternative is the usage of control flow and/or.'
      end

      def inspect(file, source, tokens, ast)
        on_node(:if, ast) do |node|
          # discard ternary ops and modifier if/unless nodes
          next unless node.loc.respond_to?(:keyword) &&
            node.loc.respond_to?(:else)

          add_offence(:convention, node.loc.line, error_message) if check(node)
        end
      end
    end

    class WhileUntilModifier < Cop
      include FavorModifier

      def error_message
        'Favor modifier while/until usage when you have a single-line body.'
      end

      def inspect(file, source, tokens, ast)
        on_node([:while, :until], ast) do |node|
          add_offence(:convention, node.loc.line, error_message) if check(node)
        end
      end
    end
  end
end
