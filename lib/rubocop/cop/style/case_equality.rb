# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the case equality operator(===).
      #
      # @example
      #   # bad
      #   Array === something
      #   (1..100) === 7
      #   /something/ === some_string
      #
      #   # good
      #   something.is_a?(Array)
      #   (1..100).include?(7)
      #   some_string =~ /something/
      #
      class CaseEquality < Cop
        MSG = 'Avoid the use of the case equality operator `===`.'.freeze

        def_node_matcher :case_equality?, '(send _ :=== _)'

        def on_send(node)
          case_equality?(node) { add_offense(node, location: :selector) }
        end
      end
    end
  end
end
