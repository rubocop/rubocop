# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unused block arguments.
      #
      # @example
      #
      #   do_something do |used, unused, _unused_but_allowed|
      #     puts used
      #   end
      class UnusedBlockArgument < Cop
        include UnusedArgument
        include Util

        def check_argument(variable)
          return unless variable.block_argument?

          if cop_config['IgnoreEmptyBlocks']
            _send, _args, body = *variable.scope.node
            return if body.nil?
          end

          super
        end

        def message(variable)
          message = String.new("Unused #{variable_type(variable)} - " \
                               "`#{variable.name}`.")

          return message if variable.explicit_block_local_variable?

          message << ' '

          scope = variable.scope
          all_arguments = scope.variables.each_value.select(&:block_argument?)

          message << if scope.node.lambda?
                       message_for_lambda(variable, all_arguments)
                     else
                       message_for_normal_block(variable, all_arguments)
                     end

          message
        end

        def variable_type(variable)
          if variable.explicit_block_local_variable?
            'block local variable'
          else
            'block argument'
          end
        end

        def message_for_normal_block(variable, all_arguments)
          if all_arguments.none?(&:referenced?)
            if all_arguments.count > 1
              "You can omit all the arguments if you don't care about them."
            else
              "You can omit the argument if you don't care about it."
            end
          else
            message_for_underscore_prefix(variable)
          end
        end

        def message_for_lambda(variable, all_arguments)
          message = String.new(message_for_underscore_prefix(variable))

          if all_arguments.none?(&:referenced?)
            message << ' Also consider using a proc without arguments ' \
                       'instead of a lambda if you want it ' \
                        "to accept any arguments but don't care about them."
          end

          message
        end

        def message_for_underscore_prefix(variable)
          "If it's necessary, use `_` or `_#{variable.name}` " \
          "as an argument name to indicate that it won't be used."
        end
      end
    end
  end
end
