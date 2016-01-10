# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether some constant value isn't a
      # mutable literal (e.g. array or hash).
      #
      # @example
      #   # bad
      #   CONST = [1, 2, 3]
      #
      #   # good
      #   CONST = [1, 2, 3].freeze
      class MutableConstant < Cop
        MSG = 'Freeze mutable objects assigned to constants.'.freeze

        def on_casgn(node)
          _scope, _const_name, value = *node

          return if value && !value.mutable_literal?

          add_offense(value, :expression)
        end

        def autocorrect(node)
          expr = node.source_range
          ->(corrector) { corrector.replace(expr, "#{expr.source}.freeze") }
        end
      end
    end
  end
end
