# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for usages of `unless` which can be replaced by `if` with inverted condition.
      # Code without `unless` is easier to read, but that is subjective, so this cop
      # is disabled by default.
      #
      # Methods that can be inverted should be defined in `InverseMethods`. Note that
      # the relationship of inverse methods needs to be defined in both directions.
      # For example,
      #
      # [source,yaml]
      # ----
      # InverseMethods:
      #   :!=: :==
      #   :even?: :odd?
      #   :odd?: :even?
      # ----
      #
      # will suggest both `even?` and `odd?` to be inverted, but only `!=` (and not `==`).
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the method
      #   and its inverse method are both defined on receiver, and also are
      #   actually inverse of each other.
      #
      # @example
      #   # bad (simple condition)
      #   foo unless !bar
      #   foo unless x != y
      #   foo unless x >= 10
      #   foo unless x.even?
      #
      #   # good
      #   foo if bar
      #   foo if x == y
      #   foo if x < 10
      #   foo if x.odd?
      #
      #   # bad (complex condition)
      #   foo unless x != y || x.even?
      #
      #   # good
      #   foo if x == y && x.odd?
      #
      #   # good (if)
      #   foo if !condition
      #
      class InvertibleUnlessCondition < Base
        extend AutoCorrector

        MSG = 'Favor `if` with inverted condition over `unless`.'

        def on_if(node)
          return unless node.unless?

          condition = node.condition
          return unless invertible?(condition)

          add_offense(node) do |corrector|
            corrector.replace(node.loc.keyword, node.inverse_keyword)
            autocorrect(corrector, condition)
          end
        end

        private

        def invertible?(node)
          case node.type
          when :begin
            invertible?(node.children.first)
          when :send
            return false if inheritance_check?(node)

            node.method?(:!) || inverse_methods.key?(node.method_name)
          when :or, :and
            invertible?(node.lhs) && invertible?(node.rhs)
          else
            false
          end
        end

        def inheritance_check?(node)
          argument = node.first_argument
          node.method?(:<) &&
            (argument.const_type? && argument.short_name.to_s.upcase != argument.short_name.to_s)
        end

        def autocorrect(corrector, node)
          case node.type
          when :begin
            autocorrect(corrector, node.children.first)
          when :send
            autocorrect_send_node(corrector, node)
          when :or, :and
            corrector.replace(node.loc.operator, node.inverse_operator)
            autocorrect(corrector, node.lhs)
            autocorrect(corrector, node.rhs)
          end
        end

        def autocorrect_send_node(corrector, node)
          if node.method?(:!)
            corrector.remove(node.loc.selector)
          else
            corrector.replace(node.loc.selector, inverse_methods[node.method_name])
          end
        end

        def inverse_methods
          @inverse_methods ||= cop_config['InverseMethods']
        end
      end
    end
  end
end
