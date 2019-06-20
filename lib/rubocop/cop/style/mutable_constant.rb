# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether some constant value isn't a
      # mutable literal (e.g. array or hash).
      #
      # Strict mode can be used to freeze all constants, rather than
      # just literals.
      # Strict mode is considered an experimental feature. It has not been
      # updated with an exhaustive list of all methods that will produce
      # frozen objects so there is a decent chance of getting some false
      # positives. Luckily, there is no harm in freezing an already
      # frozen object.
      #
      # @example EnforcedStyle: literals (default)
      #   # bad
      #   CONST = [1, 2, 3]
      #
      #   # good
      #   CONST = [1, 2, 3].freeze
      #
      #   # good
      #   CONST = <<~TESTING.freeze
      #     This is a heredoc
      #   TESTING
      #
      #   # good
      #   CONST = Something.new
      #
      #
      # @example EnforcedStyle: strict
      #   # bad
      #   CONST = Something.new
      #
      #   # bad
      #   CONST = Struct.new do
      #     def foo
      #       puts 1
      #     end
      #   end
      #
      #   # good
      #   CONST = Something.new.freeze
      #
      #   # good
      #   CONST = Struct.new do
      #     def foo
      #       puts 1
      #     end
      #   end.freeze
      class MutableConstant < Cop
        include FrozenStringLiteral
        include ConfigurableEnforcedStyle

        MSG = 'Freeze mutable objects assigned to constants.'

        def on_casgn(node)
          _scope, _const_name, value = *node
          on_assignment(value)
        end

        def on_or_asgn(node)
          lhs, value = *node

          return unless lhs&.casgn_type?

          on_assignment(value)
        end

        def autocorrect(node)
          expr = node.source_range

          lambda do |corrector|
            splat_value = splat_value(node)
            if splat_value
              correct_splat_expansion(corrector, expr, splat_value)
            elsif node.array_type? && !node.bracketed?
              corrector.insert_before(expr, '[')
              corrector.insert_after(expr, ']')
            elsif requires_parentheses?(node)
              corrector.insert_before(expr, '(')
              corrector.insert_after(expr, ')')
            end

            corrector.insert_after(expr, '.freeze')
          end
        end

        private

        def on_assignment(value)
          if style == :strict
            strict_check(value)
          else
            check(value)
          end
        end

        def strict_check(value)
          return if immutable_literal?(value)
          return if operation_produces_immutable_object?(value)
          return if frozen_string_literal?(value)

          add_offense(value)
        end

        def check(value)
          range_enclosed_in_parentheses = range_enclosed_in_parentheses?(value)

          return unless mutable_literal?(value) ||
                        range_enclosed_in_parentheses
          return if FROZEN_STRING_LITERAL_TYPES.include?(value.type) &&
                    frozen_string_literals_enabled?

          add_offense(value)
        end

        def mutable_literal?(value)
          value&.mutable_literal?
        end

        def immutable_literal?(node)
          node.nil? || node.immutable_literal?
        end

        def frozen_string_literal?(node)
          FROZEN_STRING_LITERAL_TYPES.include?(node.type) &&
            frozen_string_literals_enabled?
        end

        def requires_parentheses?(node)
          node.range_type? ||
            (node.send_type? && node.loc.dot.nil?)
        end

        def correct_splat_expansion(corrector, expr, splat_value)
          if range_enclosed_in_parentheses?(splat_value)
            corrector.replace(expr, "#{splat_value.source}.to_a")
          else
            corrector.replace(expr, "(#{splat_value.source}).to_a")
          end
        end

        def_node_matcher :splat_value, <<~PATTERN
          (array (splat $_))
        PATTERN

        # Some of these patterns may not actually return an immutable object,
        # but we want to consider them immutable for this cop.
        def_node_matcher :operation_produces_immutable_object?, <<~PATTERN
          {
            (const _ _)
            (send (const nil? :Struct) :new ...)
            (block (send (const nil? :Struct) :new ...) ...)
            (send _ :freeze)
            (send {float int} {:+ :- :* :** :/ :% :<<} _)
            (send _ {:+ :- :* :** :/ :%} {float int})
            (send _ {:== :=== :!= :<= :>= :< :>} _)
            (send (const nil? :ENV) :[] _)
            (or (send (const nil? :ENV) :[] _) _)
            (send _ {:count :length :size} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
        PATTERN

        def_node_matcher :range_enclosed_in_parentheses?, <<~PATTERN
          (begin ({irange erange} _ _))
        PATTERN
      end
    end
  end
end
