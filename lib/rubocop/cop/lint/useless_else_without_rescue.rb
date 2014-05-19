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

        MSG = '`else` without `rescue` is useless.'
        private_constant :MSG

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
