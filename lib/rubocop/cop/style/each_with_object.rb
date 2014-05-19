# encoding: utf-8

module Rubocop
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
        private_constant :MSG, :METHODS

        def on_block(node)
          method, args, body = *node
          _, method_name, method_args = *method

          return unless METHODS.include? method_name
          return if method_args.type == :sym
          return_value = body.children.last
          return unless return_value.type == :lvar
          first_arg, = *args
          accumulator_var = *first_arg
          return_var = *return_value
          return unless accumulator_var == return_var

          add_offense(method, :selector, format(MSG, method_name))
        end
      end
    end
  end
end
