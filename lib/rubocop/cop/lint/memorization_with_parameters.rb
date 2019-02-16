# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks potentially buggy usages of the ||= operators that
      # store dynamic values in instance variables based on method parameters.
      #
      # @example
      #
      #   # bad
      #   def foo(bar)
      #     @foo ||= baz(bar)
      #   end
      #
      #   # bad
      #   def foo(bar)
      #     @foo ||= "Test #{bar}"
      #   end
      #
      #   # good
      #   def foo(bar)
      #     @foo ||= {}
      #     @foo[bar] ||= baz(bar)
      #   end
      class MemorizationWithParameters < Cop
        MSG = 'Use an instance variable such as a Hash to store method' \
              ' returns called with parameter(s).'.freeze

        def_node_search :memoization, '(or_asgn (ivasgn _) $_)'
        def_node_search :contains_argument?, '(lvar %1)'

        def on_def(node)
          memoization(node.body) do |assignment|
            node.arguments.each do |arg|
              next unless contains_argument?(assignment, arg.children.first)

              add_offense(node)
              break
            end
          end
        end
      end
    end
  end
end
