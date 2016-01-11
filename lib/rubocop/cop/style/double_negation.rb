# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of double negation (!!) to convert something
      # to a boolean value. As this is both cryptic and usually redundant, it
      # should be avoided.
      #
      # @example
      #
      #   # bad
      #   !!something
      #
      #   # good
      #   !something.nil?
      #
      # Please, note that when something is a boolean value
      # !!something and !something.nil? are not the same thing.
      # As you're unlikely to write code that can accept values of any type
      # this is rarely a problem in practice.
      class DoubleNegation < Cop
        MSG = 'Avoid the use of double negation (`!!`).'.freeze

        def_node_matcher :double_negative?, '(send (send _ :!) :!)'

        def on_send(node)
          return unless double_negative?(node) && node.loc.selector.is?('!')
          add_offense(node, :selector)
        end
      end
    end
  end
end
