# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the case equality operator(===).
      class CaseEquality < Cop
        MSG = 'Avoid the use of the case equality operator `===`.'.freeze

        def_node_matcher :case_equality?, '(send _ :=== _)'

        def on_send(node)
          case_equality?(node) { add_offense(node, :selector) }
        end
      end
    end
  end
end
