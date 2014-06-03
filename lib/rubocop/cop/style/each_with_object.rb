# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop looks for inject / reduce calls where the passed in object is
      # returned at the end and so could be replace by each_with_object without
      # the need to return the object at the end.
      #
      # @example
      #   # bad
      #   [1, 2].inject({}) { |a, e| a[e] = e; a }
      #
      #   # good
      #   [1, 2].each_with_object({}) { |e, a| a[e] = e }
      class EachWithObject < Cop
        MSG = 'Use `each_with_object` instead of `%s`.'
        METHODS = [:inject, :reduce]

        def on_block(node)
          method, args, body = *node

          # filter out super and zsuper nodes
          return unless method.type == :send

          _, method_name, method_args = *method

          return unless METHODS.include? method_name
          return if method_args && method_args.type == :sym

          return_value = return_value(body)
          return unless return_value

          return unless first_argument_returned?(args, return_value)

          add_offense(method, :selector, format(MSG, method_name))
        end

        private

        def return_value(body)
          return unless body

          return_value = body.type == :begin ? body.children.last : body
          return_value if return_value && return_value.type == :lvar
        end

        def first_argument_returned?(args, return_value)
          first_arg, = *args
          accumulator_var = *first_arg
          return_var = *return_value

          accumulator_var == return_var
        end
      end
    end
  end
end
