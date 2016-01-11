# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for inject / reduce calls where the passed in object is
      # returned at the end and so could be replace by each_with_object without
      # the need to return the object at the end.
      #
      # However, we can't replace with each_with_object if the accumulator
      # parameter is assigned to within the block.
      #
      # @example
      #   # bad
      #   [1, 2].inject({}) { |a, e| a[e] = e; a }
      #
      #   # good
      #   [1, 2].each_with_object({}) { |e, a| a[e] = e }
      class EachWithObject < Cop
        MSG = 'Use `each_with_object` instead of `%s`.'.freeze
        METHODS = [:inject, :reduce].freeze

        def on_block(node)
          method, args, body = *node

          # filter out super and zsuper nodes
          return unless method.type == :send

          _, method_name, method_arg = *method

          return unless METHODS.include? method_name
          return if method_arg && method_arg.basic_literal?

          return_value = return_value(body)
          return unless return_value

          return unless first_argument_returned?(args, return_value)

          # if the accumulator parameter is assigned to in the block,
          # then we can't convert to each_with_object
          first_arg, = *args
          accumulator_var, = *first_arg
          return if body.each_descendant.any? do |n|
            next unless n.assignment?
            lhs, _rhs = *n
            lhs.equal?(accumulator_var)
          end

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
          accumulator_var, = *first_arg
          return_var, = *return_value

          accumulator_var == return_var
        end
      end
    end
  end
end
