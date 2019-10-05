# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Style
      # This cop checks for non-local control flow (`raise`, `break`,
      # `return`, `next`, etc.) used in ternary expressions.
      #
      # @example
      #
      #   # bad
      #   foo? ? raise(BarError) : baz
      #
      #   # bad
      #   foo? ? fail(BarError) : baz
      #
      #   # bad
      #   foo? ? return : bar
      #
      #   # bad
      #   foo? ? break : bar
      #
      #   # bad
      #   foo? ? next : bar
      #
      class NonLocalControlFlowInTernary < Cop
        MSG = 'Avoid non-local control flow in ternary expressions.'

        def on_if(node)
          return unless node.ternary?

          node.each_branch do |branch|
            add_offense(branch) if non_local_control_flow?(branch)
          end
        end

        private

        def_node_matcher :non_local_control_flow?, <<~PATTERN
          {(send nil? {:raise :fail} ...) return break next}
        PATTERN
      end
    end
  end
end
