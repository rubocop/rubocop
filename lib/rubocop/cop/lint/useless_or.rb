# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for useless OR (`||`) expressions.
      #
      # Some methods always return a truthy value, even when called
      # on `nil` (e.g. `nil.to_i` evaluates to `0`). Therefore, OR expressions
      # appended after these methods will never evaluate.
      #
      # @safety
      #   This cop is unsafe because the receiver might override
      #   the method to return a falsey value.
      #
      # @example
      #
      #   # bad
      #   x.to_a || fallback
      #   x.to_c || fallback
      #   x.to_d || fallback
      #   x.to_i || fallback
      #   x.to_f || fallback
      #   x.to_h || fallback
      #   x.to_r || fallback
      #   x.to_s || fallback
      #
      #   # good - if fallback is same as return value of method called on nil
      #   x.to_a # nil.to_a returns []
      #   x.to_c # nil.to_c returns (0+0i)
      #   x.to_d # nil.to_d returns 0.0
      #   x.to_i # nil.to_i returns 0
      #   x.to_f # nil.to_f returns 0.0
      #   x.to_h # nil.to_h returns {}
      #   x.to_r # nil.to_r returns (0/1)
      #   x.to_s # nil.to_s returns ''
      #
      #   # good - if the intention is not to call the method on nil
      #   x&.to_a || fallback
      #   x&.to_c || fallback
      #   x&.to_d || fallback
      #   x&.to_i || fallback
      #   x&.to_f || fallback
      #   x&.to_h || fallback
      #   x&.to_r || fallback
      #   x&.to_s || fallback
      #
      class UselessOr < Base
        MSG = 'Fallback will never evaluate because `%<source>s` always returns a truthy value.'

        TRUTHY_RETURN_VALUE_METHODS = Set[:to_a, :to_c, :to_d, :to_i, :to_f, :to_h, :to_r,
                                          :to_s].freeze

        # @!method truthy_return_value_method?(node)
        def_node_matcher :truthy_return_value_method?, <<~PATTERN
          (send _ %TRUTHY_RETURN_VALUE_METHODS)
        PATTERN

        def on_or(node)
          if truthy_return_value_method?(node.lhs)
            report_offense(node, node.lhs)
          elsif truthy_return_value_method?(node.rhs)
            parent = node.parent
            parent = parent.parent if parent&.begin_type?

            report_offense(parent, node.rhs) if parent&.or_type?
          end
        end

        private

        def report_offense(or_node, truthy_node)
          add_offense(or_node.loc.operator.join(or_node.rhs.source_range),
                      message: format(MSG, source: truthy_node.source))
        end
      end
    end
  end
end
