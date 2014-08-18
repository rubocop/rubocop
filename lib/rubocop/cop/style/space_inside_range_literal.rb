# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for spaces inside range literals.
      # @example
      #   # bad
      #   1 .. 3
      #
      #   # good
      #   1..3
      #
      #   # bad
      #   'a' .. 'z'
      #
      #   # good
      #   'a'..'z'
      class SpaceInsideRangeLiteral < Cop
        MSG = 'Space inside range literal.'

        def on_irange(node)
          check(node)
        end

        def on_erange(node)
          check(node)
        end

        private

        def check(node)
          expression = node.loc.expression.source
          operator = node.loc.operator.source.gsub(/\./, '\.')

          return unless expression =~ /(\s#{operator})|(#{operator}\s)/

          add_offense(node, :expression)
        end

        def autocorrect(node)
          expression = node.loc.expression.source
          operator = node.loc.operator.source
          operator_escaped = operator.gsub(/\./, '\.')

          @corrections << lambda do |corrector|
            corrector.replace(
              node.loc.expression,
              expression
                .sub(/\s+#{operator_escaped}/, operator)
                .sub(/#{operator_escaped}\s+/, operator)
            )
          end
        end
      end
    end
  end
end
