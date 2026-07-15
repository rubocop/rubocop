# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for calls to methods and references to constants that are documented
      # as deprecated with a YARD `@deprecated` tag.
      #
      # The check is powered by the project-wide index, so it only runs when
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed.
      # Without the index the cop does nothing.
      #
      # Only references that can be resolved without type inference are checked:
      # constants, method calls without an explicit receiver (or with `self`),
      # which are looked up in the enclosing class or module and its ancestry,
      # and calls whose receiver is a constant, which are looked up in that
      # namespace's singleton class. Calls on arbitrary objects are not checked.
      #
      # References made from a definition that is itself deprecated are allowed,
      # so deprecated implementations can keep calling each other.
      #
      # @example
      #   # Given a deprecated method and constant:
      #   #
      #   #   class Api
      #   #     # @deprecated Use `#new_method` instead.
      #   #     def old_method
      #   #     end
      #   #
      #   #     # @deprecated
      #   #     OLD_TIMEOUT = 10
      #   #   end
      #
      #   # bad
      #   class Client < Api
      #     def call
      #       old_method
      #     end
      #
      #     def timeout
      #       OLD_TIMEOUT
      #     end
      #   end
      #
      #   # good
      #   class Client < Api
      #     def call
      #       new_method
      #     end
      #
      #     def timeout
      #       NEW_TIMEOUT
      #     end
      #   end
      #
      class DeprecatedReference < Base
        include ProjectIndexHelp

        METHOD_MSG = 'Method `%<name>s` is deprecated%<detail>s'
        CONSTANT_MSG = 'Constant `%<name>s` is deprecated%<detail>s'

        DEPRECATED_TAG = '@deprecated'
        DEPRECATION_DETAIL = /#{DEPRECATED_TAG}\s+(.+)/.freeze

        def on_new_investigation
          @namespace_cache = {}
          super
        end

        def on_send(node)
          return unless project_index

          declaration = method_declaration_for(node)
          return unless declaration && deprecated?(declaration)
          return if within_deprecated_definition?(node)

          message = format(METHOD_MSG, name: node.method_name, detail: detail_for(declaration))
          add_offense(node.loc.selector, message: message)
        end
        alias on_csend on_send

        def on_const(node)
          return unless project_index
          return if node.parent&.defined_module

          declaration = resolve_constant_node(node)
          return unless declaration && deprecated?(declaration)
          return if within_deprecated_definition?(node)

          message = format(CONSTANT_MSG, name: node.const_name, detail: detail_for(declaration))
          add_offense(node, message: message)
        end

        private

        def method_declaration_for(node)
          receiver = node.receiver

          if receiver.nil? || receiver.self_type?
            implicit_receiver_declaration(node)
          elsif receiver.const_type?
            const_receiver_declaration(node, receiver)
          end
        end

        def implicit_receiver_declaration(node)
          namespace = enclosing_namespace(node)
          return nil unless namespace.is_a?(Rubydex::Namespace)

          if singleton_context?(node)
            singleton_member(namespace, "#{node.method_name}()")
          else
            namespace.find_member("#{node.method_name}()")
          end
        end

        def const_receiver_declaration(node, receiver)
          namespace = resolve_constant_node(receiver)
          return nil unless namespace.is_a?(Rubydex::Namespace)

          singleton_member(namespace, "#{node.method_name}()")
        end

        def enclosing_namespace(node)
          namespace_node = node.each_ancestor(:class, :module).first
          return project_index['Object'] unless namespace_node

          @namespace_cache.fetch(namespace_node) do
            @namespace_cache[namespace_node] = resolve_constant_node(namespace_node.identifier)
          end
        end

        # Resolves a constant the way Ruby does: the first segment through the
        # lexical nesting and every following segment inside the previous one.
        # (Qualified names cannot be passed to `resolve_constant` as a whole,
        # since it only applies the nesting to the full name.)
        def resolve_constant_node(const_node)
          segments = const_node.const_name.split('::')
          nesting = const_node.absolute? ? [] : lexical_nesting(const_node)

          declaration = project_index.resolve_constant(segments.first, nesting)
          segments.drop(1).each do |segment|
            return nil unless declaration.is_a?(Rubydex::Namespace)

            declaration = project_index.resolve_constant(segment, [declaration.name])
          end

          declaration
        end

        def lexical_nesting(node)
          node.each_ancestor(:class, :module)
              .map { |ancestor| ancestor.identifier.const_name }.reverse
        end

        # A namespace without any singleton method has no singleton-class
        # declaration of its own, so the lookup starts from the first ancestor
        # that has one; its `find_member` covers the rest of the chain.
        def singleton_member(namespace, member_name)
          namespace.ancestors.each do |ancestor|
            singleton = singleton_of(ancestor)
            return singleton.find_member(member_name) if singleton
          end

          nil
        end

        def singleton_of(namespace)
          project_index["#{namespace.name}::<#{namespace.name.split('::').last}>"]
        end

        # Whether an implicit-receiver call runs with the class or module itself
        # as `self` (directly in a namespace body, in a singleton method, or
        # inside `class << self`) rather than inside an instance method.
        def singleton_context?(node)
          instance_def_seen = false

          node.each_ancestor do |ancestor|
            case ancestor.type
            when :defs, :sclass
              return true
            when :def
              instance_def_seen = true
            when :class, :module
              return !instance_def_seen
            end
          end

          false
        end

        def deprecated?(declaration)
          definitions = declaration.definitions.to_a

          definitions.any? && definitions.all?(&:deprecated?)
        end

        # References from a definition that is itself documented as deprecated
        # are allowed.
        def within_deprecated_definition?(node)
          node.each_ancestor(:any_def, :class, :module).any? do |ancestor|
            comments = processed_source.ast_with_comments[ancestor]
            comments.any? { |comment| comment.text.include?(DEPRECATED_TAG) }
          end
        end

        def detail_for(declaration)
          text = deprecation_text(declaration)
          return '.' if text.nil? || text.empty?

          text.end_with?('.') ? ": #{text}" : ": #{text}."
        end

        def deprecation_text(declaration)
          tag_comment = declaration.definitions.to_a.filter_map do |definition|
            definition.comments.to_a.map(&:string).find { |string| string.include?(DEPRECATED_TAG) }
          end.first

          tag_comment && tag_comment[DEPRECATION_DETAIL, 1]&.strip
        end
      end
    end
  end
end
