# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where `Integer#even?` or `Integer#odd?`
      # can be used.
      #
      # @example
      #
      #   # bad
      #   if x % 2 == 0
      #   end
      #
      #   # good
      #   if x.even?
      #   end
      class EvenOdd < Cop
        MSG = 'Replace with `Integer#%<method>s?`.'.freeze

        def_node_matcher :even_odd_candidate?, <<-PATTERN
          (send
            {(send $_ :% (int 2))
             (begin (send $_ :% (int 2)))}
            ${:== :!=}
            (int ${0 1 2}))
        PATTERN

        def on_send(node)
          even_odd_candidate?(node) do |_base_number, method, arg|
            replacement_method = replacement_method(arg, method)
            add_offense(node, message: format(MSG, method: replacement_method))
          end
        end

        def autocorrect(node)
          even_odd_candidate?(node) do |base_number, method, arg|
            replacement_method = replacement_method(arg, method)

            correction = "#{base_number.source}.#{replacement_method}?"
            ->(corrector) { corrector.replace(node.source_range, correction) }
          end
        end

        private

        def replacement_method(arg, method)
          case arg
          when 0
            method == :== ? :even : :odd
          when 1
            method == :== ? :odd : :even
          end
        end
      end
    end
  end
end
