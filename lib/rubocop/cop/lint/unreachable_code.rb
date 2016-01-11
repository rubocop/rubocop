# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unreachable code.
      # The check are based on the presence of flow of control
      # statement in non-final position in *begin*(implicit) blocks.
      class UnreachableCode < Cop
        MSG = 'Unreachable code detected.'.freeze

        NODE_TYPES = [:return, :next, :break, :retry, :redo].freeze
        FLOW_COMMANDS = [:throw, :raise, :fail].freeze

        def on_begin(node)
          expressions = *node

          expressions.each_cons(2) do |e1, e2|
            next unless NODE_TYPES.include?(e1.type) || flow_command?(e1)
            add_offense(e2, :expression)
          end
        end

        private

        def flow_command?(node)
          FLOW_COMMANDS.any? { |c| node.command?(c) }
        end
      end
    end
  end
end
