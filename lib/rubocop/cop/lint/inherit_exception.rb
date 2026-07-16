# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Looks for error classes inheriting from `Exception`.
      # It is configurable to suggest using either `StandardError` (default) or
      # `RuntimeError` instead.
      #
      # @safety
      #   This cop's autocorrection is unsafe because `rescue` that omit
      #   exception class handle `StandardError` and its subclasses,
      #   but not `Exception` and its subclasses.
      #
      # When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is
      # installed, indirect inheritance is also detected: a class whose parent
      # (defined anywhere in the project) ultimately inherits from `Exception`
      # is reported, without autocorrection.
      #
      # @example EnforcedStyle: standard_error (default)
      #   # bad
      #
      #   class C < Exception; end
      #
      #   C = Class.new(Exception)
      #
      #   # good
      #
      #   class C < StandardError; end
      #
      #   C = Class.new(StandardError)
      #
      # @example EnforcedStyle: runtime_error
      #   # bad
      #
      #   class C < Exception; end
      #
      #   C = Class.new(Exception)
      #
      #   # good
      #
      #   class C < RuntimeError; end
      #
      #   C = Class.new(RuntimeError)
      class InheritException < Base
        include ConfigurableEnforcedStyle
        include ProjectIndexHelp
        extend AutoCorrector

        MSG = 'Inherit from `%<prefer>s` instead of `Exception`.'
        INDIRECT_MSG = 'Inherit from `%<prefer>s` instead of `Exception` (inherited via `%<via>s`).'
        PREFERRED_BASE_CLASS = {
          runtime_error: 'RuntimeError',
          standard_error: 'StandardError'
        }.freeze

        RESTRICT_ON_SEND = %i[new].freeze

        # @!method class_new_call?(node)
        def_node_matcher :class_new_call?, <<~PATTERN
          (send
            (const {cbase nil?} :Class) :new
            $(const {cbase nil?} _))
        PATTERN

        def on_class(node)
          parent_class = node.parent_class
          return unless parent_class

          if exception_class?(parent_class)
            return if inherit_exception_class_with_omitted_namespace?(node)

            add_offense(parent_class, message: message(parent_class)) do |corrector|
              corrector.replace(parent_class, preferred_base_class)
            end
          elsif (via = inherits_exception_via(node, parent_class))
            # No autocorrection: the `Exception` inheritance lives at another
            # class' definition site, possibly in another file.
            message = format(INDIRECT_MSG, prefer: preferred_base_class, via: via)
            add_offense(parent_class, message: message)
          end
        end

        def on_send(node)
          constant = class_new_call?(node)
          return unless constant && exception_class?(constant)

          message = message(constant)

          add_offense(constant, message: message) do |corrector|
            corrector.replace(constant, preferred_base_class)
          end
        end

        private

        def message(node)
          format(MSG, prefer: preferred_base_class, current: node.const_name)
        end

        def exception_class?(class_node)
          class_node.const_name == 'Exception'
        end

        # When `AllCops/UseProjectIndex` is enabled, indirect inheritance is
        # detected by walking the parent's indexed ancestry: `Exception` itself
        # is not indexed, so a chain ending in it shows up as an ancestor whose
        # superclass reference is unresolved and literally named `Exception`.
        # Returns the name of that ancestor, or `nil`.
        def inherits_exception_via(node, parent_class)
          return nil unless project_index && parent_class.const_type?

          declaration = resolve_in_index(node, parent_class)
          return nil unless declaration.is_a?(Rubydex::Class)

          exception_ancestor(declaration)&.name
        rescue StandardError
          nil
        end

        def exception_ancestor(declaration)
          declaration.ancestors.find do |ancestor|
            ancestor.is_a?(Rubydex::Class) && exception_superclass_reference?(ancestor)
          end
        end

        def exception_superclass_reference?(ancestor)
          ancestor.definitions.any? do |definition|
            next false unless definition.is_a?(Rubydex::ClassDefinition)

            superclass = definition.superclass
            superclass.is_a?(Rubydex::UnresolvedConstantReference) &&
              superclass.name.delete_prefix('::') == 'Exception'
          end
        end

        def resolve_in_index(node, parent_class)
          segments = parent_class.const_name.split('::')

          declaration = project_index.resolve_constant(
            segments.first, lexical_nesting(node, parent_class)
          )
          segments.drop(1).each do |segment|
            return nil unless declaration.is_a?(Rubydex::Namespace)

            declaration = project_index.resolve_constant(segment, [declaration.name])
          end

          declaration
        end

        # The superclass expression resolves in the scopes enclosing the class
        # definition, not inside it.
        def lexical_nesting(node, parent_class)
          return [] if parent_class.absolute?

          node.each_ancestor(:class, :module)
              .map { |ancestor| ancestor.identifier.const_name }.reverse
        end

        def inherit_exception_class_with_omitted_namespace?(class_node)
          return false if class_node.parent_class.namespace&.cbase_type?

          class_node.left_siblings.any? do |sibling|
            sibling.respond_to?(:identifier) && exception_class?(sibling.identifier)
          end
        end

        def preferred_base_class
          PREFERRED_BASE_CLASS[style]
        end
      end
    end
  end
end
