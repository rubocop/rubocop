# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for optional arguments to methods
      # that do not come at the end of the argument list
      #
      # @example
      #   # bad
      #   def foo(a = 1, b, c)
      #   end
      #
      #   # good
      #   def baz(a, b, c = 1)
      #   end
      #
      #   def foobar(a = 1, b = 2, c = 3)
      #   end
      class OptionalArguments < Cop
        MSG = 'Optional arguments should appear at the end ' \
              'of the argument list.'.freeze

        def on_def(node)
          _method, arguments, = *node
          arguments = *arguments

          each_misplaced_optional_arg(arguments) do |argument|
            arg, = *argument
            add_offense(argument, :expression, format(MSG, arg))
          end
        end

        private

        def each_misplaced_optional_arg(arguments)
          optarg_positions, arg_positions = argument_positions(arguments)
          return if optarg_positions.empty? || arg_positions.empty?

          optarg_positions.each do |optarg_position|
            # there can only be one group of optional arguments
            break if optarg_position > arg_positions.max

            yield arguments[optarg_position]
          end
        end

        def argument_positions(arguments)
          optarg_positions = []
          arg_positions = []

          arguments.each_with_index do |argument, index|
            optarg_positions << index if argument.optarg_type?
            arg_positions << index if argument.arg_type?
          end

          [optarg_positions, arg_positions]
        end
      end
    end
  end
end
