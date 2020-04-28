# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for `raise` or `fail` statements which are
      # raising `Exception` class.
      #
      # You can specify a module name that will be an implicit namespace
      # using `AllowedImplicitNamespaces` option. The cop cause a false positive
      # for namespaced `Exception` when a namespace is omitted. This option can
      # prevent the false positive by specifying a namespace to be omitted for
      # `Exception`. Alternatively, make `Exception` a fully qualified class
      # name with an explicit namespace.
      #
      # @example
      #   # bad
      #   raise Exception, 'Error message here'
      #
      #   # good
      #   raise StandardError, 'Error message here'
      #
      # @example AllowedImplicitNamespaces: ['Gem']
      #   # good
      #   module Gem
      #     def self.foo
      #       raise Exception # This exception means `Gem::Exception`.
      #     end
      #   end
      class RaiseException < Cop
        MSG = 'Use `StandardError` over `Exception`.'

        def_node_matcher :exception?, <<~PATTERN
          (send nil? {:raise :fail} (const ${cbase nil?} :Exception) ... )
        PATTERN

        def_node_matcher :exception_new_with_message?, <<~PATTERN
          (send nil? {:raise :fail}
            (send (const ${cbase nil?} :Exception) :new ... ))
        PATTERN

        def on_send(node)
          exception?(node, &check(node)) ||
            exception_new_with_message?(node, &check(node))
        end

        private

        def check(node)
          lambda do |cbase|
            return if cbase.nil? && implicit_namespace?(node)

            add_offense(node)
          end
        end

        def implicit_namespace?(node)
          return false unless (parent = node.parent)

          if parent.module_type?
            namespace = parent.identifier.source

            return allow_implicit_namespaces.include?(namespace)
          end

          implicit_namespace?(parent)
        end

        def allow_implicit_namespaces
          cop_config['AllowedImplicitNamespaces'] || []
        end
      end
    end
  end
end
