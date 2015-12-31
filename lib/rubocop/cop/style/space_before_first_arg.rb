# encoding: utf-8

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

        MSG = 'Put one space between the method name and the first argument.'

        def on_send(node)
          return if parentheses?(node)

          _receiver, method_name, *args = *node
          return if args.empty?
          return if operator?(method_name)
          return if node.asgn_method_call?

          arg1 = args.first.source_range
          return if arg1.line > node.loc.line
          return if allow_for_alignment? && aligned_with_something?(arg1)

          arg1_with_space = range_with_surrounding_space(arg1, :left)
          space = Parser::Source::Range.new(arg1.source_buffer,
                                            arg1_with_space.begin_pos,
                                            arg1.begin_pos)
          add_offense(space, space) if space.length > 1
        end

        def autocorrect(range)
          ->(corrector) { corrector.replace(range, ' ') }
        end
      end
    end
  end
end
