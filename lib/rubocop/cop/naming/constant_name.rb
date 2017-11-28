# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks whether constant names are written using
      # SCREAMING_SNAKE_CASE.
      #
      # To avoid false positives, it ignores cases in which we cannot know
      # for certain the type of value that would be assigned to a constant.
      #
      # @example
      #   # bad
      #   InchInCm = 2.54
      #   INCHinCM = 2.54
      #   Inch_In_Cm = 2.54
      #
      #   # good
      #   INCH_IN_CM = 2.54
      class ConstantName < Cop
        MSG = 'Use SCREAMING_SNAKE_CASE for constants.'.freeze
        SNAKE_CASE = /^[\dA-Z_]+$/

        def on_casgn(node)
          _scope, const_name, value = *node

          # We cannot know the result of method calls like
          # NewClass = something_that_returns_a_class
          # It's also ok to assign a class constant another class constant
          # SomeClass = SomeOtherClass
          return if value && (%i[block const casgn].include?(value.type) ||
                    value.send_type? && value.method_name != :freeze)

          add_offense(node, location: :name) if const_name !~ SNAKE_CASE
        end
      end
    end
  end
end
