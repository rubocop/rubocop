# encoding: utf-8

module Rubocop
  module Cop
    module FavorModifier
      # TODO extremely ugly solution that needs lots of polish
      def check(sexp)
        # discard if/then/else
        return false if sexp.src.respond_to?(:else) && sexp.src.else

        if %w(if while).include?(sexp.src.keyword.to_source)
          cond, body = *sexp
        else
          cond, _else, body = *sexp
        end

        if length(sexp) > 3
          false
        else
          cond_length = sexp.src.keyword.size + cond.src.expression.size + 1
          body_length = body_length(body)

          (cond_length + body_length) <= LineLength.max
        end
      end

      def length(sexp)
        sexp.src.expression.to_source.split("\n").size
      end

      def body_length(body)
        if body
          body.src.expression.column + body.src.expression.size
        else
          0
        end
      end
    end

    class IfUnlessModifier < Cop
      include FavorModifier

      def self.portable?
        true
      end

      def error_message
        'Favor modifier if/unless usage when you have a single-line body. ' +
          'Another good alternative is the usage of control flow and/or.'
      end

      def inspect(file, source, sexp)
        on_node(:if, sexp) do |node|
          # discard ternary ops and modifier if/unless nodes
          next unless node.src.respond_to?(:keyword) &&
            node.src.respond_to?(:else)

          add_offence(:convention, node.src.line, error_message) if check(node)
        end
      end
    end

    class WhileUntilModifier < Cop
      include FavorModifier

      def self.portable?
        true
      end

      def error_message
        'Favor modifier while/until usage when you have a single-line body.'
      end

      def inspect(file, source, sexp)
        on_node([:while, :until], sexp) do |node|
          add_offence(:convention, node.src.line, error_message) if check(node)
        end
      end
    end
  end
end
