# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for uses of global exception variables like `$!` and `$@`.
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
      class GlobalExceptionVars < Base
        MSG_EXCEPTION_VAR = 'Avoid implicit exception variable `%<var>s`. ' \
                            'Use explicit exception variable in rescue instead.'
        MSG_BACKTRACE_VAR = 'Avoid implicit backtrace variable `%<var>s`. ' \
                            'Use `.backtrace` in rescue instead.'

        EXCEPTION_VARS = %i[$! $ERROR_INFO].freeze
        BACKTRACE_VARS = %i[$@ $ERROR_POSITION].freeze

        def on_gvar(node)
          check_implicit_var(node)
        end

        def on_gvasgn(node)
          check_implicit_var(node)
        end

        private

        def check_implicit_var(node)
          if BACKTRACE_VARS.include?(node.name)
            add_offense(node, message: format(MSG_BACKTRACE_VAR, var: node.name))
          elsif EXCEPTION_VARS.include?(node.name)
            add_offense(node, message: format(MSG_EXCEPTION_VAR, var: node.name))
          end
        end
      end
    end
  end
end
