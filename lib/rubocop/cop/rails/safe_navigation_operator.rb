# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # Checks for use of `#try` or `#try!`.
      class SafeNavigationOperator < Cop
        MSG = 'Prefer `&.` over `ActiveSupport#try!`.'
        INVALID_METHODS = [:try!]

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless valid_method? method_name, args
          add_offense(node, :selector)
        end

        private

        def valid_method?(method_name, args)
          INVALID_METHODS << :try if cop_config['CaptureTry']

          INVALID_METHODS.include?(method_name) && args.length > 0
        end
      end
    end
  end
end
