# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for if and unless statements that would fit on one line
      # if written as a modifier if/unless.
      # The maximum line length is configurable.
      class IfUnlessModifier < Cop
        include StatementModifier

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
          return unless fit_within_line_as_modifier_form?(node)
          add_offense(node, :keyword, message(node.loc.keyword.source))
        end

        def autocorrect(node)
          cond, body, _else = if_node_parts(node)

          oneline =
            "#{body.loc.expression.source} #{node.loc.keyword.source} " +
            cond.loc.expression.source
          first_line_comment = processed_source.comments.find do |c|
            c.loc.line == node.loc.line
          end
          if first_line_comment
            oneline << ' ' << first_line_comment.loc.expression.source
          end

          ->(corrector) { corrector.replace(node.loc.expression, oneline) }
        end
      end
    end
  end
end
