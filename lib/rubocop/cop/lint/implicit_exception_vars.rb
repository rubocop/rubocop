# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for uses of implicit exception variables like `$!` and `$@`.
      # These variables are unsafe because they reference the _last_ exception
      # raised, which can change unexpectedly in complex code.
      #
      # Using explicit exception variables in rescue blocks is clearer and safer.
      #
      # @example
      #   # bad
      #   begin
      #     do_something
      #   rescue
      #     puts $!
      #     puts $@
      #   end
      #
      #   # bad
      #   begin
      #     do_something
      #   rescue
      #     puts $ERROR_INFO
      #     puts $ERROR_POSITION
      #   end
      #
      #   # good
      #   begin
      #     do_something
      #   rescue => e
      #     puts e
      #     puts e.backtrace
      #   end
      #
      #   # good
      #   begin
      #     do_something
      #   rescue StandardError => error
      #     puts error
      #     puts error.backtrace
      #   end
      class ImplicitExceptionVars < Base
        MSG = 'Avoid implicit exception variables `%<var>s`. ' \
              'Use explicit exception variable in rescue instead.'

        IMPLICIT_VARS = %i[$! $@ $ERROR_INFO $ERROR_POSITION].freeze

        def on_gvar(node)
          return unless IMPLICIT_VARS.include?(node.name)

          add_offense(node, message: format(MSG, var: node.name))
        end
      end
    end
  end
end
