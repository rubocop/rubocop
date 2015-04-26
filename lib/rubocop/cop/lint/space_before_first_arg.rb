# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # Checks for space between a method name and the first argument for
      # method calls without parentheses.
      #
      # @example
      #
      #   something?x
      #   something!x
      #
      class SpaceBeforeFirstArg < Cop
        MSG = 'Put space between the method name and the first argument.'

        def on_send(node)
          return if parentheses?(node)

          _receiver, method_name, *args = *node
          return if args.empty?
          return if operator?(method_name)
          return if method_name.to_s.end_with?('=')

          # Setter calls with parentheses are parsed this way. The parentheses
          # belong to the argument, not the send node.
          return if args.first.type == :begin

          arg1 = args.first.loc.expression
          arg1_with_space = range_with_surrounding_space(arg1, :left)
          space = Parser::Source::Range.new(arg1.source_buffer,
                                            arg1_with_space.begin_pos,
                                            arg1.begin_pos)

          add_offense(space, arg1) if arg1_with_space.source =~ /\A\S/
        end

        def autocorrect(range)
          ->(corrector) { corrector.insert_before(range, ' ') }
        end
      end
    end
  end
end
