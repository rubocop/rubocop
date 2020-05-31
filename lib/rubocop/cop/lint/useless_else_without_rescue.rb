# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for useless `else` in `begin..end` without `rescue`.
      #
      # NOTE: This syntax is no longer valid on Ruby 2.6 or higher and
      # this cop is going to be removed at some point the future.
      #
      # @example
      #
      #   # bad
      #
      #   begin
      #     do_something
      #   else
      #     do_something_else # This will never be run.
      #   end
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   rescue
      #     handle_errors
      #   else
      #     do_something_else
      #   end
      class UselessElseWithoutRescue < Cop
        include ParserDiagnostic

        MSG = '`else` without `rescue` is useless.'

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :useless_else
        end

        def find_offense_node_by(diagnostic)
          # TODO: When implementing auto-correction, this method should return
          # an offense node passed as first argument of `add_offense` method.
        end

        def alternative_message(_diagnostic)
          MSG
        end
      end
    end
  end
end
