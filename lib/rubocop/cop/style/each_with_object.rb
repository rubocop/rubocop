# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for inject / reduce calls where the passed in object is
      # returned at the end and so could be replaced by each_with_object without
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
          return unless reduce_method?(method)

          _, method_name, method_arg = *method
          return if simple_method_arg?(method_arg)

          return_value = return_value(body)
          return unless return_value
          return unless first_argument_returned?(args, return_value)
          return if accumulator_param_assigned_to?(body, args)

          add_offense(node, method.loc.selector, format(MSG, method_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            method, args, _body = *node
            corrector.replace(method.loc.selector, 'each_with_object')
            first_arg, second_arg = *args
            corrector.replace(first_arg.loc.expression, second_arg.source)
            corrector.replace(second_arg.loc.expression, first_arg.source)
          end
        end

        private

        def reduce_method?(method)
          return false unless method.send_type?

          _, method_name, _method_arg = *method
          METHODS.include? method_name
        end

        def simple_method_arg?(method_arg)
          method_arg && method_arg.basic_literal?
        end

        # if the accumulator parameter is assigned to in the block,
        # then we can't convert to each_with_object
        def accumulator_param_assigned_to?(body, args)
          first_arg, = *args
          accumulator_var, = *first_arg

          body.each_descendant.any? do |n|
            next unless n.assignment?

            lhs, _rhs = *n
            lhs.equal?(accumulator_var)
          end
        end

        def return_value(body)
          return unless body

          return_value = body.begin_type? ? body.children.last : body
          return_value if return_value && return_value.lvar_type?
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
