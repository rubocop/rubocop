# encoding: utf-8

module Rubocop
  module Cop
    class ConstantName < Cop
      MSG = 'Use SCREAMING_SNAKE_CASE for constants.'
      SNAKE_CASE = /^[\dA-Z_]+$/

      def inspect(file, source, tokens, ast)
        on_node(:cdecl, ast) do |node|
          _scope, const_name, value = *node

          # we cannot know the result of method calls
          next if value.type == :send

          unless const_name =~ SNAKE_CASE
            add_offence(:convention,
                        node.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
