# encoding: utf-8
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
      class SpaceBeforeFirstArg < Cop
        include PrecedingFollowingAlignment

        MSG = 'Put one space between the method name and ' \
              'the first argument.'.freeze

        def on_send(node)
          return unless regular_method_call_with_params?(node)
          return unless expect_params_after_method_name?(node)

          _receiver, _method_name, *args = *node
          arg1 = args.first.source_range
          arg1_with_space = range_with_surrounding_space(arg1, :left)
          space = range_between(arg1_with_space.begin_pos, arg1.begin_pos)
          add_offense(space, space) if space.length > 1
        end

        def autocorrect(range)
          ->(corrector) { corrector.replace(range, ' ') }
        end

        private

        def regular_method_call_with_params?(node)
          _receiver, method_name, *args = *node

          !(args.empty? || operator?(method_name) || node.asgn_method_call?)
        end

        def expect_params_after_method_name?(node)
          return false if parentheses?(node)

          _receiver, _method_name, *args = *node
          arg1 = args.first.source_range

          arg1.line == node.loc.line &&
            !(allow_for_alignment? && aligned_with_something?(arg1))
        end
      end
    end
  end
end
