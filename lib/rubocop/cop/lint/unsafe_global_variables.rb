# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for uses of unsafe global variables.
      #
      # @example
      #
      #   # bad
      #   $!
      #
      #   # bad
      #   $ERROR_INFO
      #
      #   # bad
      #   $@
      #
      #   # bad
      #   $ERROR_POSITION
      #
      class UnsafeGlobalVariables < Base
        MSG = 'Do not use unsafe global variable `%<global_variable>s`.'

        # built-in global variables and their English aliases
        # https://www.zenspider.com/ruby/quickref.html
        UNSAFE_GLOBAL_VARIABLES = %i[$! $ERROR_INFO $@ $ERROR_POSITION].freeze

        def on_gvar(node)
          global_variable, = *node

          return unless UNSAFE_GLOBAL_VARIABLES.include?(global_variable)

          add_offense(node.loc.name, message: format(MSG, global_variable: global_variable))
        end
      end
    end
  end
end
