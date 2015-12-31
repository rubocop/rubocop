# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for if and unless statements that would fit on one line
      # if written as a modifier if/unless.
      # The maximum line length is configurable.
      class IfUnlessModifier < Cop
        include StatementModifier

        ASSIGNMENT_TYPES = [:lvasgn, :casgn, :cvasgn, :gvasgn, :ivasgn, :masgn]

        def message(keyword)
          "Favor modifier `#{keyword}` usage when having a single-line body." \
          ' Another good alternative is the usage of control flow `&&`/`||`.'
        end

        def on_if(node)
          # discard ternary ops, if/else and modifier if/unless nodes
          return if ternary_op?(node)
          return if modifier_if?(node)
          return if elsif?(node)
          return if if_else?(node)
          return if chained?(node)
          return unless fit_within_line_as_modifier_form?(node)
          add_offense(node, :keyword, message(node.loc.keyword.source))
        end

        def chained?(node)
          # Don't register offense for `if ... end.method`
          return false if node.parent.nil? || !node.parent.send_type?
          receiver = node.parent.children[0]
          node.equal?(receiver)
        end

        def parenthesize?(node)
          # Parenthesize corrected expression if changing to modifier-if form
          # would change the meaning of the parent expression
          # (due to the low operator precedence of modifier-if)
          return false if node.parent.nil?
          return true if ASSIGNMENT_TYPES.include?(node.parent.type)

          if node.parent.send_type?
            _receiver, _name, *args = *node.parent
            return !method_uses_parens?(node.parent, args.first)
          end

          false
        end

        def method_uses_parens?(node, limit)
          source = node.source_range.source_line[0...limit.loc.column]
          source =~ /\s*\(\s*$/
        end

        def autocorrect(node)
          cond, body, _else = if_node_parts(node)

          oneline =
            "#{body.source} #{node.loc.keyword.source} " + cond.source
          first_line_comment = processed_source.comments.find do |c|
            c.loc.line == node.loc.line
          end
          if first_line_comment
            oneline << ' ' << first_line_comment.loc.expression.source
          end
          oneline = "(#{oneline})" if parenthesize?(node)

          ->(corrector) { corrector.replace(node.source_range, oneline) }
        end
      end
    end
  end
end
