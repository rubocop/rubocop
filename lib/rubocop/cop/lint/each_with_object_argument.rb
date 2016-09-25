# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks if each_with_object is called with an immutable
      # argument. Since the argument is the object that the given block shall
      # make calls on to build something based on the enumerable that
      # each_with_object iterates over, an immutable argument makes no sense.
      # It's definitely a bug.
      #
      # @example
      #
      #   sum = numbers.each_with_object(0) { |e, a| a += e }
      class EachWithObjectArgument < Cop
        MSG = 'The argument to each_with_object can not be immutable.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless method_name == :each_with_object
          return unless args.length == 1

          arg = args.first
          add_offense(node, :expression) if arg.immutable_literal?
        end
      end
    end
  end
end
