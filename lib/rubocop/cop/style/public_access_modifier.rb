# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for explicit usage of the `public` access modifier.
      #
      # This cop can be used to prevent methods from accidentally becoming
      # public when they are added after an explicit `public` modifier later in
      # a class or module body.
      #
      # @example
      #   # bad
      #   class Foo
      #     private
      #
      #     def bar; end
      #
      #     public
      #
      #     def baz; end
      #   end
      #
      #   # bad
      #   public def foo; end
      #
      #   # good
      #   class Foo
      #     def baz; end
      #
      #     private
      #
      #     def bar; end
      #   end
      #
      class PublicAccessModifier < Base
        MSG = 'Do not use the explicit `public` access modifier.'

        RESTRICT_ON_SEND = %i[public].freeze

        def on_send(node)
          return unless node.access_modifier?

          add_offense(node.loc.selector)
        end
        alias on_csend on_send
      end
    end
  end
end
