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

        def_node_matcher :shadowed_parameter?, <<-PATTERN
          (def _ (args (arg $_)) (or_asgn (ivasgn _) (send _ _ (lvar $_))))
        PATTERN

        def on_def(node)
          return unless shadowed_parameter?(node)

          add_offense(node)
        end
      end
    end
  end
end
