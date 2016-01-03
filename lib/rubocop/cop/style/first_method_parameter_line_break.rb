# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for a line break before the first parameter in a
      # multi-line method parameter definition.
      #
      # @example
      #
      #     # bad
      #     def method(foo, bar,
      #         baz)
      #       do_something
      #     end
      #
      #     # good
      #     def method(
      #         foo, bar,
      #         baz)
      #       do_something
      #     end
      #
      #     # ignored
      #     def method foo,
      #         bar
      #       do_something
      #     end
      class FirstMethodParameterLineBreak < Cop
        include OnMethodDef
        include FirstElementLineBreak

        MSG = 'Add a line break before the first parameter of a ' \
              'multi-line method parameter list.'.freeze

        def on_method_def(node, _method_name, args, _body)
          check_method_line_break(node, args.to_a)
        end
      end
    end
  end
end
