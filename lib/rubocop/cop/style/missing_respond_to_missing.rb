# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for the presence of `method_missing` without also
      # defining `respond_to_missing?`.
      #
      # Not defining `respond_to_missing?` will cause metaprogramming
      # methods like `respond_to?` to behave unexpectedly:
      #
      # [source,ruby]
      # ----
      # class StringDelegator
      #   def initialize(string)
      #     @string = string
      #   end
      #
      #   def method_missing(name, *args)
      #     @string.send(name, *args)
      #   end
      # end
      #
      # delegator = StringDelegator.new("foo")
      # # Claims to not respond to `upcase`.
      # delegator.respond_to?(:upcase) # => false
      # # But you can call it.
      # delegator.upcase # => FOO
      # ----
      #
      # When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is
      # installed, `respond_to_missing?` defined in another definition of the
      # same class or module (e.g. a reopening in another file) also
      # satisfies the check.
      #
      # @example
      #   # bad
      #   def method_missing(name, *args)
      #     if @delegate.respond_to?(name)
      #       @delegate.send(name, *args)
      #     else
      #       super
      #     end
      #   end
      #
      #   # good
      #   def respond_to_missing?(name, include_private)
      #     @delegate.respond_to?(name) || super
      #   end
      #
      #   def method_missing(name, *args)
      #     if @delegate.respond_to?(name)
      #       @delegate.send(name, *args)
      #     else
      #       super
      #     end
      #   end
      #
      class MissingRespondToMissing < Base
        include ProjectIndexHelp

        MSG = 'When using `method_missing`, define `respond_to_missing?`.'

        def on_def(node)
          return unless node.method?(:method_missing)
          return if implements_respond_to_missing?(node)
          return if respond_to_missing_elsewhere?(node)

          add_offense(node)
        end
        alias on_defs on_def

        private

        # When `AllCops/UseProjectIndex` is enabled, `respond_to_missing?`
        # defined in another definition of the same class or module (e.g. a
        # reopening in another file) also satisfies the check. Ancestors are
        # not consulted: overriding `method_missing` warrants a matching
        # `respond_to_missing?` for the same class.
        def respond_to_missing_elsewhere?(node)
          return false unless project_index
          return false unless (namespace_node = node.each_ancestor(:class, :module).first)

          declaration = resolve_in_index(namespace_node)
          return false unless declaration.is_a?(Rubydex::Namespace)

          scope = singleton_definition?(node) ? singleton_of(declaration) : declaration
          !scope&.member('respond_to_missing?()').nil?
        rescue StandardError
          false
        end

        def singleton_definition?(node)
          node.defs_type? || node.each_ancestor(:sclass, :class, :module).first&.sclass_type?
        end

        def singleton_of(declaration)
          project_index["#{declaration.name}::<#{declaration.name.split('::').last}>"]
        end

        def resolve_in_index(namespace_node)
          segments = namespace_node.identifier.const_name.split('::')

          declaration = project_index.resolve_constant(
            segments.first, lexical_nesting(namespace_node)
          )
          segments.drop(1).each do |segment|
            return nil unless declaration.is_a?(Rubydex::Namespace)

            declaration = project_index.resolve_constant(segment, [declaration.name])
          end

          declaration
        end

        def lexical_nesting(namespace_node)
          return [] if namespace_node.identifier.absolute?

          namespace_node.each_ancestor(:class, :module)
                        .map { |ancestor| ancestor.identifier.const_name }.reverse
        end

        def implements_respond_to_missing?(node)
          scope = enclosing_scope(node)
          search_root = scope || node.parent
          return false unless search_root

          search_root.each_descendant(node.type).any? do |descendant|
            descendant.method?(:respond_to_missing?) && enclosing_scope(descendant).equal?(scope)
          end
        end

        # The class/module/`class << self` body that lexically contains `node`,
        # or `nil` when `node` is defined at the top level.
        def enclosing_scope(node)
          node.each_ancestor(:class, :module, :sclass).first
        end
      end
    end
  end
end
