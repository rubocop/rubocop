# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for `super` calls with explicit arguments that pass the wrong
      # number of positional arguments to the overridden implementation, using
      # the project index.
      #
      # The check is powered by the project-wide index, so it only runs when
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed.
      # Without the index the cop does nothing.
      #
      # Only `super` inside a plain instance method defined directly in a class
      # body is considered, and only when the enclosing class resolves in the
      # index and its entire ancestry is resolved, so a superclass method coming
      # from a gem, the standard library, or a dynamic definition never produces
      # an offense. The overridden implementation is the first ancestor after
      # the enclosing class in the index's method resolution order that defines
      # the method; when it is not a plain method definition (an `attr_*` or an
      # alias) or its definitions disagree on arity, the call is not checked.
      # Calls that forward arguments (`*`, `**`, `...`) are skipped, and bare
      # `super` (which forwards the current method's parameters) is not checked.
      # Methods the index attributes to `Object`, `Kernel`, or `BasicObject`
      # are never used as the overridden implementation, since a `def` inside
      # a block at the top level (`Struct.new do ... end`) is indexed under
      # `Object` even though it defines a method somewhere else entirely.
      #
      # @example
      #   # Given the project defines:
      #   #   class Base
      #   #     def initialize(name, size); end
      #   #   end
      #
      #   # bad
      #   class Widget < Base
      #     def initialize(name)
      #       super(name)
      #     end
      #   end
      #
      #   # good
      #   class Widget < Base
      #     def initialize(name)
      #       super(name, 0)
      #     end
      #   end
      #
      class SuperArgumentMismatch < Base
        include ProjectIndexHelp
        include IndexedMethodArity

        MSG = 'Wrong number of arguments to `super` ' \
              '(given %<given>d, expected %<expected>s for `%<parent>s#%<method>s`).'

        # Blocks that change what method (or scope) `super` refers to, or in
        # which `super` is not statically resolvable.
        CONTEXT_CHANGING_BLOCKS = %i[
          define_method define_singleton_method class_eval class_exec
          module_eval module_exec instance_eval instance_exec refine
        ].freeze

        # Methods the index attributes to the root namespaces are not
        # trustworthy super targets: a `def` inside a block at the top level
        # (`Struct.new do ... end`, `Class.new do ... end`) is indexed under
        # `Object` even though it defines a method somewhere else entirely.
        BUILTIN_ROOTS = %w[Object Kernel BasicObject].freeze

        def on_super(node)
          return unless project_index

          def_node = enclosing_instance_method(node)
          return unless def_node

          shape, parent = resolved_super_shape(def_node)
          return unless shape

          min, max, has_keywords = shape
          given = positional_argument_count(node, has_keywords)
          return if given.nil? || arity_satisfied?(given, min, max)

          add_offense(node.loc.keyword,
                      message: message(def_node.method_name, parent, given, min, max))
        end

        private

        def message(method_name, parent, given, min, max)
          format(MSG, given: given, expected: expected_range(min, max),
                      parent: parent.name, method: method_name)
        end

        # The `def` node whose method the `super` call re-dispatches, or nil
        # when the context is not statically known: `super` inside a
        # singleton method, inside `define_method` or an eval/refine block,
        # or outside any method.
        def enclosing_instance_method(node)
          node.each_ancestor(:any_def, :any_block, :sclass).each do |ancestor|
            case ancestor.type
            when :def then return ancestor
            when :defs, :sclass then return nil
            else
              return nil if CONTEXT_CHANGING_BLOCKS.include?(ancestor.method_name)
            end
          end

          nil
        end

        # `[[min, max, has_keywords], parent]` for the implementation `super`
        # dispatches to, or nil when the enclosing class or the overridden
        # method is not statically known.
        def resolved_super_shape(def_node)
          declaration = enclosing_class_declaration(def_node)
          return nil unless declaration
          return nil unless fully_resolved_index_ancestry?(declaration, ignore_extend: true)

          super_method_shape(declaration, def_node.method_name)
        rescue StandardError
          nil
        end

        # The index declaration of the class whose body directly contains
        # `def_node`, or nil when the method is not defined directly in a
        # class body (module methods are excluded because their `super`
        # target depends on where the module is mixed in) or the class does
        # not resolve in the index.
        def enclosing_class_declaration(def_node)
          class_node = def_node.each_ancestor(:class, :module, :sclass, :any_block).first
          return nil unless class_node&.class_type?

          declaration = project_index[lexical_nesting_of(def_node).join('::')]
          return nil unless declaration.is_a?(Rubydex::Namespace)
          return nil unless declared_at?(declaration, class_node)

          declaration
        end

        # Whether one of the declaration's definitions is the given class
        # node, anchoring the name-based lookup to the source being
        # inspected (a qualified identifier like `class Foo::Bar` can
        # resolve to a namespace other than the joined nesting names).
        def declared_at?(declaration, class_node)
          declaration.definitions.any? do |definition|
            location = definition.location
            location.uri.start_with?(FILE_URI_PREFIX) &&
              location.to_display.start_line == class_node.first_line &&
              same_file?(location.to_file_path, processed_source.file_path)
          end
        end

        # The shape of the first implementation of `method_name` after the
        # enclosing class in the index's method resolution order, or nil
        # when no indexed ancestor defines it (e.g. it comes from a gem or
        # the standard library, which are not indexed).
        def super_method_shape(declaration, method_name)
          ancestors = declaration.ancestors.to_a
          position = ancestors.index { |ancestor| ancestor.name == declaration.name }
          return nil unless position

          ancestors.drop(position + 1).each do |ancestor|
            return nil if BUILTIN_ROOTS.include?(ancestor.name)

            member = ancestor.member("#{method_name}()")
            next unless member

            # The first definer along the chain is the receiving
            # implementation; when its shape is unknown there is nothing
            # further to check.
            shape = indexed_member_shape(member)
            return shape && [shape, ancestor]
          end

          nil
        end
      end
    end
  end
end
