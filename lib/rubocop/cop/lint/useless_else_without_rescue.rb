# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for useless `else` in `begin..end` without `rescue`.
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

        MSG = '`else` without `rescue` is useless.'.freeze

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :useless_else
        end

        def alternative_message(_diagnostic)
          MSG
        end
      end
    end
  end
end
