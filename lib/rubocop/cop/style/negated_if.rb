# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered.
      class NegatedIf < Cop
        include NegativeConditional

        MSG = 'Favor `%s` over `%s` for negative conditions.'.freeze

        def on_if(node)
          return unless node.loc.respond_to?(:keyword)
          return if node.loc.keyword.is?('elsif')

          check_negative_conditional(node)
        end

        def message(node)
          if node.loc.keyword.is?('if')
            format(MSG, 'unless', 'if')
          else
            format(MSG, 'if', 'unless')
          end
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            condition, _body, _rest = *node
            # look inside parentheses around the condition
            condition = condition.children.first while condition.type == :begin
            # unwrap the negated portion of the condition (a send node)
            pos_condition, _method, = *condition
            corrector.replace(
              node.loc.keyword,
              node.loc.keyword.is?('if') ? 'unless' : 'if'
            )
            corrector.replace(condition.source_range, pos_condition.source)
          end
        end
      end
    end
  end
end
