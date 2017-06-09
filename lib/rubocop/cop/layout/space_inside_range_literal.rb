# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside range literals.
      #
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
        MSG = 'Space inside range literal.'.freeze

        def on_irange(node)
          check(node)
        end

        def on_erange(node)
          check(node)
        end

        private

        def check(node)
          expression = node.source
          op = node.loc.operator.source
          escaped_op = op.gsub(/\./, '\.')

          # account for multiline range literals
          expression.sub!(/#{escaped_op}\n\s*/, op)

          return unless expression =~ /(\s#{escaped_op})|(#{escaped_op}\s)/

          add_offense(node)
        end

        def autocorrect(node)
          expression = node.source
          operator = node.loc.operator.source
          operator_escaped = operator.gsub(/\./, '\.')

          lambda do |corrector|
            corrector.replace(
              node.source_range,
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
