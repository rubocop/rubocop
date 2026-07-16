# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for private instance methods that are not referenced anywhere
      # in the project.
      #
      # The check is powered by the project-wide index, so it only runs when
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed.
      # Without the index the cop does nothing.
      #
      # A method counts as referenced when a call with its name appears anywhere
      # in the indexed project (regardless of the receiver), when it is the source
      # of an `alias`, or when its name appears in the same file as a symbol or
      # inside a string literal (covering `send(:name)` and declarative DSLs like
      # `before_action :name`). Methods defined in classes or modules with
      # descendants are not checked, since they may be invoked through `super`
      # or inherited dispatch, and neither are methods whose names are built
      # dynamically (e.g. `send("do_#{action}")`).
      #
      # The cop is disabled by default because symbol-based references from
      # *other* files (e.g. a Rails callback declared in a concern) cannot be
      # detected and would be reported as false positives. It is best suited
      # for occasional dead-code sweeps rather than permanent enforcement.
      #
      # @example
      #   # bad - `helper` is never referenced anywhere in the project
      #   class Service
      #     def call
      #       do_something
      #     end
      #
      #     private
      #
      #     def helper
      #     end
      #   end
      #
      #   # good
      #   class Service
      #     def call
      #       do_something(helper)
      #     end
      #
      #     private
      #
      #     def helper
      #     end
      #   end
      #
      class UnusedPrivateMethod < Base
        include ProjectIndexHelp

        MSG = 'Private method `%<method>s` appears to be unused.'

        IDENTIFIER_PATTERN = /[a-zA-Z_]\w*[?!=]?/.freeze

        # Methods invoked implicitly by the Ruby runtime.
        IMPLICITLY_INVOKED_METHODS = %i[initialize initialize_copy initialize_clone
                                        initialize_dup method_missing respond_to_missing?
                                        marshal_dump marshal_load].to_set.freeze

        class << self
          # The reference-name set is derived once per index and shared by the
          # per-file cop instances.
          def reference_names_cache
            @reference_names_cache ||= {}.compare_by_identity
          end
        end

        def on_new_investigation
          @literal_names = nil
          super
        end

        def on_def(node)
          return unless project_index

          declaration = checkable_declaration(node)
          return unless declaration
          return if referenced?(node.method_name)
          return if owner_with_descendants?(declaration) || override?(declaration, node.method_name)

          message = format(MSG, method: node.method_name)
          add_offense(node.loc.keyword.join(node.loc.name), message: message)
        end

        private

        def checkable_declaration(node)
          return nil if IMPLICITLY_INVOKED_METHODS.include?(node.method_name)
          return nil if node.each_ancestor(:any_def, :any_block, :sclass).any?
          return nil unless (namespace_node = node.each_ancestor(:class, :module).first)

          declaration = method_declaration(node, namespace_node)
          declaration if declaration&.private?
        end

        def method_declaration(node, namespace_node)
          namespace = resolve_constant_in_index(namespace_node.identifier)
          return nil unless namespace.is_a?(Rubydex::Namespace)

          namespace.member("#{node.method_name}()")
        end

        def referenced?(method_name)
          name = method_name.to_s

          referenced_names.include?(name) || literal_names.include?(name)
        end

        def referenced_names
          self.class.reference_names_cache[project_index] ||=
            project_index.method_references
                         .to_set { |reference| reference.name.delete_suffix('()') }
        end

        # Symbol literals and identifier-like tokens inside string literals in the
        # current file, covering `send(:name)`, declarative DSLs like
        # `before_action :name` and names embedded in strings (e.g. node-pattern
        # `#helper` references).
        def literal_names
          @literal_names ||=
            processed_source.ast.each_descendant(:sym, :str)
                            .with_object(Set.new) do |literal, names|
              if literal.sym_type?
                names << literal.value.to_s
              else
                literal.value.scan(IDENTIFIER_PATTERN) { |token| names << token }
              end
            end
        end

        # A method defined in a class or module with descendants may be invoked
        # through `super` or inherited dispatch, which the index does not track.
        def owner_with_descendants?(declaration)
          owner = declaration.owner
          return false unless owner.is_a?(Rubydex::Namespace)

          owner.descendants.any? { |descendant| descendant.name != owner.name }
        end

        # An override of an inherited method may be invoked polymorphically
        # (e.g. a framework hook), even when no direct reference exists.
        def override?(declaration, method_name)
          owner = declaration.owner
          return false unless owner.is_a?(Rubydex::Namespace)

          owner.ancestors.any? do |ancestor|
            ancestor.name != owner.name && ancestor.member("#{method_name}()")
          end
        end
      end
    end
  end
end
