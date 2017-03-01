# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that exactly one space is used between a method name and the
      # first argument for method calls without parentheses.
      #
      # Alternatively, extra spaces can be added to align the argument with
      # something on a preceding or following line, if the AllowForAlignment
      # config parameter is true.
      #
      # @example
      #   @bad
      #   something  x
      #   something   y, z
      #
      #   @good
      #   something x
      #   something y, z
      #
      class SpaceBeforeFirstArg < Cop
        include PrecedingFollowingAlignment

        MSG = 'Put one space between the method name and ' \
              'the first argument.'.freeze

        def on_send(node)
          return unless regular_method_call_with_arguments?(node)
          return unless expect_params_after_method_name?(node)

          first_arg = node.first_argument.source_range
          first_arg_with_space = range_with_surrounding_space(first_arg, :left)
          space = range_between(first_arg_with_space.begin_pos,
                                first_arg.begin_pos)

          add_offense(space, space) if space.length > 1
        end

        def autocorrect(range)
          ->(corrector) { corrector.replace(range, ' ') }
        end

        private

        def regular_method_call_with_arguments?(node)
          node.arguments? && !node.operator_method? && !node.setter_method?
        end

        def expect_params_after_method_name?(node)
          return false if node.parenthesized?

          first_arg = node.first_argument

          same_line?(first_arg, node) &&
            !(allow_for_alignment? &&
              aligned_with_something?(first_arg.source_range))
        end
      end
    end
  end
end
