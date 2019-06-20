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
        include RangeHelp

        MSG = 'Use `each_with_object` instead of `%<method>s`.'
        METHODS = %i[inject reduce].freeze

        def_node_matcher :each_with_object_candidate?, <<~PATTERN
          (block $(send _ {:inject :reduce} _) $_ $_)
        PATTERN

        def on_block(node)
          each_with_object_candidate?(node) do |method, args, body|
            _, method_name, method_arg = *method
            return if simple_method_arg?(method_arg)

            return_value = return_value(body)
            return unless return_value
            return unless first_argument_returned?(args, return_value)
            return if accumulator_param_assigned_to?(body, args)

            add_offense(node, location: method.loc.selector,
                              message: format(MSG, method: method_name))
          end
        end

        # rubocop:disable Metrics/AbcSize
        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.send_node.loc.selector, 'each_with_object')

            first_arg, second_arg = *node.arguments

            corrector.replace(first_arg.loc.expression, second_arg.source)
            corrector.replace(second_arg.loc.expression, first_arg.source)

            return_value = return_value(node.body)

            if return_value_occupies_whole_line?(return_value)
              corrector.remove(whole_line_expression(return_value))
            else
              corrector.remove(return_value.loc.expression)
            end
          end
        end
        # rubocop:enable Metrics/AbcSize

        private

        def simple_method_arg?(method_arg)
          method_arg&.basic_literal?
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
          return_value if return_value&.lvar_type?
        end

        def first_argument_returned?(args, return_value)
          first_arg, = *args
          accumulator_var, = *first_arg
          return_var, = *return_value

          accumulator_var == return_var
        end

        def return_value_occupies_whole_line?(node)
          whole_line_expression(node).source.strip == node.source
        end

        def whole_line_expression(node)
          range_by_whole_lines(node.loc.expression, include_final_newline: true)
        end
      end
    end
  end
end
