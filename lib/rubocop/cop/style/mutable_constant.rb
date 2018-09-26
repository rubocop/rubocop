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
      #
      #   # good
      #   CONST = <<~TESTING.freeze
      #   This is a heredoc
      #   TESTING
      class MutableConstant < Cop
        include FrozenStringLiteral

        MSG = 'Freeze mutable objects assigned to constants.'.freeze

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
            if node.array_type? && !node.bracketed?
              corrector.insert_before(expr, '[')
              corrector.insert_after(expr, '].freeze')
            elsif node.irange_type? || node.erange_type?
              corrector.insert_before(expr, '(')
              corrector.insert_after(expr, ').freeze')
            else
              corrector.insert_after(expr, '.freeze')
            end
          end
        end

        private

        def on_assignment(value)
          range_enclosed_in_parentheses = range_enclosed_in_parentheses?(value)

          value = splat_value(value) if splat_value(value)

          return unless mutable_literal?(value) ||
                        range_enclosed_in_parentheses
          return if FROZEN_STRING_LITERAL_TYPES.include?(value.type) &&
                    frozen_string_literals_enabled?

          add_offense(value)
        end

        def mutable_literal?(value)
          value && value.mutable_literal?
        end

        def_node_matcher :splat_value, <<-PATTERN
          (array (splat $_))
        PATTERN

        def_node_matcher :range_enclosed_in_parentheses?, <<-PATTERN
          (begin ({irange erange} _ _))
        PATTERN
      end
    end
  end
end
