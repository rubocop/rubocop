# encoding: utf-8
# frozen_string_literal: true

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

        include FrozenStringLiteral

        def on_casgn(node)
          _scope, _const_name, value = *node
          on_assignment(value)
        end

        def on_or_asgn(node)
          lhs, value = *node

          return unless lhs && lhs.casgn_type?

          on_assignment(value)
        end

        def autocorrect(node)
          expr = node.source_range
          lambda do |corrector|
            if node.array_type? && node.loc.begin.nil? && node.loc.end.nil?
              corrector.insert_before(expr, '[')
              corrector.insert_after(expr, '].freeze')
            else
              corrector.insert_after(expr, '.freeze')
            end
          end
        end

        private

        def on_assignment(value)
          return unless value && value.mutable_literal?
          return if FROZEN_STRING_LITERAL_TYPES.include?(value.type) &&
                    frozen_string_literals_enabled?(processed_source)

          add_offense(value, :expression)
        end
      end
    end
  end
end
