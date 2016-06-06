# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for `raise` statements which do not specify an explicit
      # exception class. (This raises a `RuntimeError`. Some projects might
      # prefer to use exception classes which more precisely identify the
      # nature of the error.)
      #
      # @example
      #   @bad
      #   raise 'Error message here'
      #
      #   @good
      #   raise ArgumentError, 'Error message here'
      class ImplicitRuntimeError < Cop
        def_node_matcher :implicit_runtime_error_raise, '(send nil :raise str)'

        def on_send(node)
          if implicit_runtime_error_raise(node)
            add_offense(node, :expression, 'Use `raise` with an explicit ' \
                                           'exception class and message, ' \
                                           'rather than just a message.')
          end
        end
      end
    end
  end
end
