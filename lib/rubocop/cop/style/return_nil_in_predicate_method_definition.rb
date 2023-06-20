# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks if `return` or `return nil` is used in predicate method definitions.
      #
      # @safety
      #   Autocorrection is marked as unsafe because the change of the return value
      #   from `nil` to `false` could potentially lead to incompatibility issues.
      #
      # @example
      #   # bad
      #   def foo?
      #     return if condition
      #
      #     do_something?
      #   end
      #
      #   # bad
      #   def foo?
      #     return nil if condition
      #
      #     do_something?
      #   end
      #
      #   # good
      #   def foo?
      #     return false if condition
      #
      #     do_something?
      #   end
      #
      # @example AllowedMethod: ['foo?']
      #   # good
      #   def foo?
      #     return if condition
      #
      #     do_something?
      #   end
      #
      # @example AllowedPattern: [/foo/]
      #   # good
      #   def foo?
      #     return if condition
      #
      #     do_something?
      #   end
      #
      class ReturnNilInPredicateMethodDefinition < Base
        extend AutoCorrector
        include AllowedMethods
        include AllowedPattern

        MSG = 'Use `return false` instead of `%<prefer>s` in the predicate method.'

        # @!method return_nil?(node)
        def_node_matcher :return_nil?, <<~PATTERN
          {(return) (return (nil))}
        PATTERN

        def on_def(node)
          return unless node.predicate_method?
          return if allowed_method?(node.method_name) || matches_allowed_pattern?(node.method_name)
          return unless (body = node.body)

          body.each_descendant(:return) do |return_node|
            next unless return_nil?(return_node)

            message = format(MSG, prefer: return_node.source)

            add_offense(return_node, message: message) do |corrector|
              corrector.replace(return_node, 'return false')
            end
          end
        end
        alias on_defs on_def
      end
    end
  end
end
