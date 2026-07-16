# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Avoid prefixing accessor method names with `get_` or `set_`.
      # Applies to both instance and class methods.
      #
      # NOTE: Method names starting with `get_` or `set_` only register an offense
      # when the methods match the expected arity for getters and setters respectively.
      # Getters (`get_attribute`) must have no arguments to be registered,
      # and setters (`set_attribute(value)`) must have exactly one.
      #
      # When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is
      # installed, methods that override a method defined by an ancestor
      # elsewhere in the project are not reported, since renaming an override
      # breaks the inherited contract.
      #
      # @example
      #   # bad
      #   def set_attribute(value)
      #   end
      #
      #   # good
      #   def attribute=(value)
      #   end
      #
      #   # bad
      #   def get_attribute
      #   end
      #
      #   # good
      #   def attribute
      #   end
      #
      #   # accepted, incorrect arity for getter
      #   def get_value(attr)
      #   end
      #
      #   # accepted, incorrect arity for setter
      #   def set_value
      #   end
      class AccessorMethodName < Base
        include ProjectIndexHelp

        MSG_READER = 'Do not prefix reader method names with `get_`.'
        MSG_WRITER = 'Do not prefix writer method names with `set_`.'

        def on_def(node)
          return unless proper_attribute_name?(node)
          return unless bad_reader_name?(node) || bad_writer_name?(node)
          return if overrides_inherited_method?(node)

          message = message(node)

          add_offense(node.loc.name, message: message)
        end
        alias on_defs on_def

        private

        def message(node)
          if bad_reader_name?(node)
            MSG_READER
          elsif bad_writer_name?(node)
            MSG_WRITER
          end
        end

        def proper_attribute_name?(node)
          !node.method_name.to_s.end_with?('!', '?', '=')
        end

        def bad_reader_name?(node)
          node.method_name.to_s.start_with?('get_') && !node.arguments?
        end

        def bad_writer_name?(node)
          node.method_name.to_s.start_with?('set_') &&
            node.arguments.one? &&
            node.first_argument.arg_type?
        end

        # When `AllCops/UseProjectIndex` is enabled, methods that override a
        # method defined by an ancestor elsewhere in the project are not
        # reported: renaming an override breaks the inherited contract.
        def overrides_inherited_method?(node)
          return false unless project_index
          return false unless (namespace_node = node.each_ancestor(:class, :module).first)

          declaration = resolve_constant_in_index(namespace_node.identifier)
          return false unless declaration.is_a?(Rubydex::Namespace)

          scope = node.defs_type? ? indexed_singleton_of(declaration) : declaration
          !scope.nil? && inherited_index_member?(scope, "#{node.method_name}()")
        rescue StandardError
          false
        end
      end
    end
  end
end
