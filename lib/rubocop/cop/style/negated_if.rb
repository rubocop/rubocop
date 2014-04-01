# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered.
      class NegatedIf < Cop
        include NegativeConditional

        def on_if(node)
          return unless node.loc.respond_to?(:keyword)
          return if node.loc.keyword.is?('elsif')

          check(node)
        end

        def error_message
          'Favor `unless` over `if` for negative conditions.'
        end

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            condition, _body, _rest = *node
            # unwrap the negated portion of the condition (a send node)
            pos_condition, _method, = *condition
            corrector.replace(node.loc.keyword, 'unless')
            corrector.replace(condition.loc.expression,
                              pos_condition.loc.expression.source)
          end
        end
      end
    end
  end
end
