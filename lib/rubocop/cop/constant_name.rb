# encoding: utf-8

module Rubocop
  module Cop
    class ConstantName < Cop
      MSG = 'Use SCREAMING_SNAKE_CASE for constants.'
      SNAKE_CASE = /^[\dA-Z_]+$/

      def on_cdecl(node)
        _scope, const_name, value = *node

        # we cannot know the result of method calls line
        # NewClass = something_that_returns_a_class
        if value.type != :send && const_name !~ SNAKE_CASE
          add_offence(:convention,
                      node.src.line,
                      MSG)
        end
      end
    end
  end
end
