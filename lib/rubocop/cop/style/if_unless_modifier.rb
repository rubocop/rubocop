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
          # Accept cases that require parentheses around modifier if statement.
          return if chained?(node)
          return unless fit_within_line_as_modifier_form?(node)
          add_offense(node, :keyword, message(node.loc.keyword.source))
        end

        def chained?(node)
          ancestor = node.ancestors.first
          ancestor && ancestor.send_type?
        end

        def autocorrect(node)
          cond, body, _else = if_node_parts(node)
          oneline = if body.if_type?
                      correction_from_inner_if_unless_modifier(body, cond)
                    else
                      "#{body.loc.expression.source} " \
                        "#{node.loc.keyword.source} " \
                        "#{cond.loc.expression.source}"
                    end

          first_line_comment = processed_source.comments.find do |c|
            c.loc.line == node.loc.line
          end

          if first_line_comment
            oneline << " #{first_line_comment.loc.expression.source}"
          end

          ->(corrector) { corrector.replace(node.loc.expression, oneline) }
        end

        def correction_from_inner_if_unless_modifier(body, cond)
          inner_condition, inner_body, = if_node_parts(body)

          "#{inner_body.loc.expression.source} " \
            "#{body.loc.keyword.source} " \
            "#{cond.loc.expression.source} && " <<
            if inner_condition.or_type?
              "(#{inner_condition.loc.expression.source})"
            else
              "#{inner_condition.loc.expression.source}"
            end
        end
      end
    end
  end
end
