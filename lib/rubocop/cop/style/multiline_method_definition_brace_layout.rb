# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that the opening and closing braces in a method
      # definition either both reside on separate lines relative to the
      # method parameters, or that they both reside on a line with method
      # parameters.
      #
      # If a method definition's opening brace is on the same line as the
      # first parameter of the definition, then the closing brace should
      # be on the same line as the last parameter of the definition.
      #
      # If a method definition's opening brace is on the line above the
      # first parameter of the definition, then the closing brace should
      # be on the line below the last parameter of the definition.
      #
      # @example
      #
      #     # bad
      #     def foo(a,
      #       b
      #       )
      #     end
      #
      #     # bad
      #     def foo(
      #       a,
      #       b)
      #     end
      #
      #     # good
      #     def foo(a,
      #       b)
      #     end
      #
      #     #good
      #     def foo(
      #       a,
      #       b
      #     )
      #     end
      class MultilineMethodDefinitionBraceLayout < Cop
        include OnMethodDef
        include MultilineLiteralBraceLayout

        SAME_LINE_MESSAGE = 'Closing method definition brace must be on the ' \
          'same line as the last parameter when opening brace is on the same ' \
          'line as the first parameter.'.freeze

        NEW_LINE_MESSAGE = 'Closing method definition brace must be on the ' \
          'line after the last parameter when opening brace is on the line ' \
          'before the first parameter.'.freeze

        def on_method_def(_node, _method_name, args, _body)
          check_brace_layout(args)
        end
      end
    end
  end
end
