# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether constant names are written using
      # SCREAMING_SNAKE_CASE.
      #
      # To avoid false positives, it ignores cases in which we cannot know
      # for certain the type of value that would be assigned to a constant.
      class ConstantName < Cop
        MSG = 'Use SCREAMING_SNAKE_CASE for constants.'.freeze
        SNAKE_CASE = /^[\dA-Z_]+$/
        CAMEL_CASE_BREAKS = /(?<=[a-z])(?=[A-Z])/

        def on_casgn(node)
          _scope, const_name, value = *node

          # We cannot know the result of method calls like
          # NewClass = something_that_returns_a_class
          # It's also ok to assign a class constant another class constant
          # SomeClass = SomeOtherClass
          return if value && %i[send block const].include?(value.type)

          add_offense(node, :name) if const_name !~ SNAKE_CASE
        end

        private

        def autocorrect(node)
          _scope, const_name, value = *node

          new_const_name = snake_const(const_name)

          lambda do |corrector|
            corrector.replace(node.source_range,
                              "#{new_const_name} = #{value.source}")
          end
        end

        def snake_const(const_name)
          const_name
            .to_s
            .split(CAMEL_CASE_BREAKS)
            .join('_')
            .upcase
        end
      end
    end
  end
end
