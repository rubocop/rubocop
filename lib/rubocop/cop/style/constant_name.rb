# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether constant names are written using
      # SCREAMING_SNAKE_CASE.
      #
      # To avoid false positives, it ignores cases in which we cannot know
      # for certain the type of value that would be assigned to a constant.
      class ConstantName < Cop
        MSG = 'Use SCREAMING_SNAKE_CASE for constants.'
        SNAKE_CASE = /^[\dA-Z_]+$/

        def on_casgn(node)
          _scope, const_name, value = *node

          # We cannot know the result of method calls line
          # NewClass = something_that_returns_a_class
          unless value && [:send, :block].include?(value.type)
            convention(node, :name) if const_name !~ SNAKE_CASE
          end
        end
      end
    end
  end
end
