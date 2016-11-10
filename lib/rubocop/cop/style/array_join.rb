# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of "*" as a substitute for *join*.
      #
      # Not all cases can reliably checked, due to Ruby's dynamic
      # types, so we consider only cases when the first argument is an
      # array literal or the second is a string literal.
      class ArrayJoin < Cop
        MSG = 'Favor `Array#join` over `Array#*`.'.freeze

        def_node_matcher :join_candidate?, '(send $array :* $str)'

        def on_send(node)
          join_candidate?(node) { add_offense(node, :selector) }
        end

        def autocorrect(node)
          array, join_arg = join_candidate?(node).map(&:source)

          lambda do |corrector|
            corrector.replace(node.source_range, "#{array}.join(#{join_arg})")
          end
        end
      end
    end
  end
end
