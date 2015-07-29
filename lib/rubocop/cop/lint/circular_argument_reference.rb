# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for circular argument references in keyword arguments.
      #
      # This cop mirrors a warning produced by MRI since 2.2.
      #
      # @example
      #   def bake(pie: pie)
      #     pie.heat_up
      #   end
      class CircularArgumentReference < Cop
        MSG = 'Circular argument reference - `%s`.'

        def on_kwoptarg(node)
          arg_name, arg_value = *node
          case arg_value.type
          when :send
            # Ruby 2.0 will have type send every time, and "send nil" if it is
            # calling itself with a specified "self" receiver
            receiver, name = *arg_value
            return unless name == arg_name && receiver.nil?
          when :lvar
            # Ruby 2.2.2 will have type lvar if it is calling its own method
            # without a specified "self"
            return unless arg_value.to_a == [arg_name]
          else
            return
          end

          add_offense(arg_value, :expression, format(MSG, arg_name))
        end
      end
    end
  end
end
