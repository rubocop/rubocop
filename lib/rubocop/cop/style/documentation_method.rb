# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for missing documentation comment for public methods.
      # It can optionally be configured to also require documentation for
      # non-public methods.
      #
      # @example
      #
      #   # bad
      #
      #   class Foo
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   module Foo
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   def foo.bar
      #     puts baz
      #   end
      #
      #   # good
      #
      #   class Foo
      #     # Documentation
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   module Foo
      #     # Documentation
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   # Documentation
      #   def foo.bar
      #     puts baz
      #   end
      #
      # @example RequireForNonPublicMethods: false (default)
      #   # good
      #   class Foo
      #     protected
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     def do_something
      #     end
      #   end
      #
      # @example RequireForNonPublicMethods: true
      #   # bad
      #   class Foo
      #     protected
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     def do_something
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     protected
      #     # Documentation
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     # Documentation
      #     def do_something
      #     end
      #   end
      #
      class DocumentationMethod < Base
        include DocumentationComment
        include DefNode

        MSG = 'Missing method documentation comment.'

        def_node_matcher :module_function_node?, <<~PATTERN
          (send nil? :module_function ...)
        PATTERN

        def on_def(node)
          parent = node.parent
          module_function_node?(parent) ? check(parent) : check(node)
        end
        alias on_defs on_def

        private

        def check(node)
          return if non_public?(node) && !require_for_non_public_methods?
          return if documentation_comment?(node)

          add_offense(node)
        end

        def require_for_non_public_methods?
          cop_config['RequireForNonPublicMethods']
        end
      end
    end
  end
end
