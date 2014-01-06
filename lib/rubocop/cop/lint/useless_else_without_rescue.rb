# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for useless `else` in `begin..end` without `rescue`.
      #
      # @example
      #   begin
      #     do_something
      #   else
      #     handle_errors # This will never be run.
      #   end
      class UselessElseWithoutRescue < Cop
        include ParserDiagnostic

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :useless_else
        end
      end
    end
  end
end
