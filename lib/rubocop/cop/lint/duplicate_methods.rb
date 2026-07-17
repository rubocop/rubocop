# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for duplicated instance (or singleton) method
      # definitions.
      #
      # NOTE: Aliasing a method to itself is allowed, as it indicates that
      # the developer intends to suppress Ruby's method redefinition warnings.
      # See https://bugs.ruby-lang.org/issues/13574.
      #
      # By default the cop can only detect duplicates within a single file.
      # When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed,
      # the cop additionally consults the project-wide index and reports methods
      # whose duplicate definition lives in another file.
      #
      # NOTE: The project index does not record whether a definition in another
      # file is wrapped in a conditional, so a platform-specific redefinition in
      # another file may still be reported. Aliasing the method to itself (see above)
      # before redefining marks the redefinition as intentional and is respected
      # across files.
      #
      # @example
      #
      #   # bad
      #   def foo
      #     1
      #   end
      #
      #   def foo
      #     2
      #   end
      #
      #   # bad
      #   def foo
      #     1
      #   end
      #
      #   alias foo bar
      #
      #   # good
      #   def foo
      #     1
      #   end
      #
      #   def bar
      #     2
      #   end
      #
      #   # good
      #   def foo
      #     1
      #   end
      #
      #   alias bar foo
      #
      #   # good
      #   alias foo foo
      #   def foo
      #     1
      #   end
      #
      #   # good
      #   alias_method :foo, :foo
      #   def foo
      #     1
      #   end
      #
      #   # bad
      #   class MyClass
      #     extend Forwardable
      #
      #     # or with: `def_instance_delegator`, `def_delegators`, `def_instance_delegators`
      #     def_delegator :delegation_target, :delegated_method_name
      #
      #     def delegated_method_name
      #     end
      #   end
      #
      #   # good
      #   class MyClass
      #     extend Forwardable
      #
      #     def_delegator :delegation_target, :delegated_method_name
      #
      #     def non_duplicated_delegated_method_name
      #     end
      #   end
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: false (default)
      #
      #   # good
      #   def foo
      #     1
      #   end
      #
      #   delegate :foo, to: :bar
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: true
      #
      #   # bad
      #   def foo
      #     1
      #   end
      #
      #   delegate :foo, to: :bar
      #
      #   # good
      #   def foo
      #     1
      #   end
      #
      #   delegate :baz, to: :bar
      #
      #   # good - delegate with splat arguments is ignored
      #   def foo
      #     1
      #   end
      #
      #   delegate :foo, **options
      #
      #   # good - delegate inside a condition is ignored
      #   def foo
      #     1
      #   end
      #
      #   if cond
      #     delegate :foo, to: :bar
      #   end
      #
      class DuplicateMethods < Base # rubocop:disable Metrics/ClassLength
        include ProjectIndexHelp

        MSG = 'Method `%<method>s` is defined at both %<defined>s and %<current>s.'

        # Method names the cop registers that can be looked up in the project index:
        # a fully qualified namespace followed by `#` (instance) or `.` (singleton)
        # and the method name.
        INDEXABLE_METHOD_NAME =
          /\A(?<owner>[A-Z]\w*(?:::[A-Z]\w*)*)(?<separator>[#.])(?<name>[^#.]+)\z/.freeze
        RESTRICT_ON_SEND = %i[alias_method attr_reader attr_writer attr_accessor attr
                              delegate def_delegator def_instance_delegator def_delegators
                              def_instance_delegators].freeze

        def initialize(config = nil, options = nil)
          super
          @definitions = {}
          @scopes = Hash.new { |hash, key| hash[key] = [] }
          @self_aliased = Set.new
        end

        def on_new_investigation
          # The self-alias trick declares an intentional redefinition only within
          # the file that uses it, so the tracked names do not carry over.
          @self_aliased = Set.new
          super
        end

        def on_def(node)
          # if a method definition is inside an if, it is very likely
          # that a different definition is used depending on platform, etc.
          return if node.each_ancestor.any?(&:if_type?)

          found_instance_method(node, node.method_name)
        end

        def on_defs(node)
          return if node.each_ancestor.any?(&:if_type?)

          if node.receiver.const_type?
            _, const_name = *node.receiver
            check_const_receiver(node, node.method_name, const_name)
          elsif node.receiver.self_type?
            check_self_receiver(node, node.method_name)
          end
        end

        # @!method method_alias?(node)
        def_node_matcher :method_alias?, <<~PATTERN
          (alias (sym $_name) (sym $_original_name))
        PATTERN

        def on_alias(node)
          name, original_name = method_alias?(node)
          return unless name && original_name

          if name == original_name
            track_self_alias(node, name)
            return
          end
          return if node.ancestors.any?(&:if_type?)

          found_instance_method(node, name)
        end

        # @!method alias_method?(node)
        def_node_matcher :alias_method?, <<~PATTERN
          (send nil? :alias_method (sym $_name) (sym $_original_name))
        PATTERN

        # @!method delegate_method?(node)
        def_node_matcher :delegate_method?, <<~PATTERN
          (send nil? :delegate
            ({sym str} $_)+
            (hash <(pair (sym :to) {sym str}) ...>)
          )
        PATTERN

        # @!method delegator?(node)
        def_node_matcher :delegator?, <<~PATTERN
          (send nil? {:def_delegator :def_instance_delegator}
            {
              {sym str} ({sym str} $_) |
              {sym str} {sym str} ({sym str} $_)
            }
          )
        PATTERN

        # @!method delegators?(node)
        def_node_matcher :delegators?, <<~PATTERN
          (send nil? {:def_delegators :def_instance_delegators}
            {sym str}
            ({sym str} $_)+
          )
        PATTERN

        # @!method sym_name(node)
        def_node_matcher :sym_name, '(sym $_name)'

        # @!method class_or_module_new_block?(node)
        def_node_matcher :class_or_module_new_block?, <<~PATTERN
          (block
            (send (const _ {:Class :Module}) :new ...)
            ...)
        PATTERN

        # @!method class_new_block?(node)
        def_node_matcher :class_new_block?, <<~PATTERN
          (block
            (send (const _ :Class) :new ...)
            ...)
        PATTERN

        def on_send(node) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          name, original_name = alias_method?(node)

          if name && original_name
            if name == original_name
              track_self_alias(node, name)
              return
            end
            return if inside_condition?(node)

            found_instance_method(node, name)
          elsif (attr = node.attribute_accessor?)
            on_attr(node, *attr)
          elsif active_support_extensions_enabled? && (names = delegate_method?(node))
            return if inside_condition?(node)

            on_delegate(node, names)
          elsif (name = delegator?(node))
            return if inside_condition?(node)

            found_instance_method(node, name)
          elsif (names = delegators?(node))
            return if inside_condition?(node)

            names.each { |name| found_instance_method(node, name) }
          end
        end

        private

        def check_const_receiver(node, name, const_name)
          qualified = lookup_constant(node, const_name)
          return unless qualified

          found_method(node, "#{qualified}.#{name}")
        end

        def check_self_receiver(node, name)
          enclosing = node.parent_module_name
          if enclosing
            found_method(node, "#{enclosing}.#{name}")
          elsif (anon_block = anonymous_class_block(node))
            scope = qualified_name(anon_block.parent_module_name, nil, 'Object')
            found_method(node, "#{scope}.#{name}", scope_id: anon_block_scope_id(anon_block))
          end
        end

        def inside_condition?(node)
          node.ancestors.any?(&:if_type?)
        end

        def message_for_dup(node, method_name, key)
          format(MSG, method: method_name, defined: source_location(@definitions[key]),
                      current: source_location(node))
        end

        def on_delegate(node, method_names)
          name_prefix = delegate_prefix(node)

          method_names.each do |name|
            name = "#{name_prefix}_#{name}" if name_prefix

            found_instance_method(node, name)
          end
        end

        def delegate_prefix(node)
          kwargs_node = node.last_argument

          return unless (prefix = hash_value(kwargs_node, :prefix))

          if prefix.true_type?
            hash_value(kwargs_node, :to).value
          elsif prefix.type?(:sym, :str)
            prefix.value
          end
        end

        def hash_value(node, key)
          node.pairs.find { |pair| pair.key.value == key }&.value
        end

        def found_instance_method(node, name)
          if (scope = node.parent_module_name)
            found_method(node, "#{humanize_scope(scope)}#{name}")
          elsif (anon_block = anonymous_class_block(node))
            base = qualified_name(anon_block.parent_module_name, nil, 'Object')
            scope = node.each_ancestor(:sclass).any? ? "#<Class:#{base}>" : base
            found_method(
              node, "#{humanize_scope(scope)}#{name}", scope_id: anon_block_scope_id(anon_block)
            )
          else
            found_sclass_method(node, name)
          end
        end

        def humanize_scope(scope)
          scope = scope.sub(
            /(?:(?<name>.*)::)#<Class:\k<name>>|#<Class:(?<name>.*)>(?:::)?/,
            '\k<name>.'
          )
          scope.end_with?('.') ? scope : "#{scope}#"
        end

        def anonymous_class_block(node)
          first_block = node.each_ancestor(:block).first
          return unless class_or_module_new_block?(first_block)
          return if first_block.parent&.type?(:lvasgn)
          return if node.each_ancestor(:sclass).any? { |s| !s.children.first.self_type? }

          first_block
        end

        def anon_block_scope_id(anon_block)
          parent = anon_block.parent
          return unless parent&.type?(:any_block, :begin, :call, :casgn, :any_def)

          if (receiver = scope_receiver(parent, anon_block))
            "#{receiver.source}.#{parent.method_name}"
          elsif !parent.begin_type? || parent.parent&.any_block_type?
            anon_block_identity(anon_block)
          end
        end

        # When a Class.new block is passed as an argument to a named-receiver
        # method call (e.g. T.cast(Class.new(Base) do ... end, ...)), the
        # receiver-based scope id (e.g. "T.cast") is the same for every call,
        # causing false positives for methods defined in distinct anonymous
        # classes. Return nil so the block falls through to the unique
        # source-location-based scope id.
        # Module.new blocks are excluded because they may be intentionally
        # mixed into the same target via prepend/include/extend.
        def scope_receiver(parent, anon_block)
          return if class_new_block?(anon_block) && parent.call_type?

          named_receiver(parent)
        end

        def named_receiver(node)
          receiver = node.receiver
          receiver unless class_or_module_new_block?(receiver)
        end

        def found_sclass_method(node, name)
          singleton_ancestor = node.each_ancestor.find(&:sclass_type?)
          return unless singleton_ancestor

          singleton_receiver_node = singleton_ancestor.children[0]
          return unless singleton_receiver_node.send_type?

          found_method(node, "#{singleton_receiver_node.method_name}.#{name}")
        end

        def found_method(node, method_name, scope_id: nil)
          key = method_key(node, method_name)
          key = "#{key}@#{scope_id}" if scope_id
          scope = node.each_ancestor(:rescue, :ensure).first&.type

          if @definitions.key?(key)
            found_redefinition(node, method_name, key, scope)
          else
            @definitions[key] = node
            check_cross_file_duplicate(node, method_name) if scope_id.nil? && scope.nil?
          end
        end

        def found_redefinition(node, method_name, key, scope)
          if scope && !@scopes[scope].include?(key)
            @definitions[key] = node
            @scopes[scope] << key
          elsif intentional_cross_file_redefinition?(node, method_name, key)
            @definitions[key] = node
          else
            add_offense(location(node), message: message_for_dup(node, method_name, key))
          end
        end

        # The self-alias trick (`alias foo foo` or `alias_method :foo, :foo` right before
        # a `def`) suppresses Ruby's method redefinition warning, signaling an intentional
        # redefinition of a method defined in another file.
        def intentional_cross_file_redefinition?(node, method_name, key)
          @self_aliased.include?(method_name) &&
            @definitions[key].source_range.source_buffer.name !=
              node.source_range.source_buffer.name
        end

        def track_self_alias(node, name)
          scope = node.parent_module_name
          return unless scope

          @self_aliased << "#{humanize_scope(scope)}#{name}"
        end

        def method_key(node, method_name)
          if (ancestor_def = node.each_ancestor(:any_def).first)
            "#{ancestor_def.method_name}.#{method_name}"
          else
            method_name
          end
        end

        def location(node)
          if node.any_def_type?
            node.loc.keyword.join(node.loc.name)
          else
            node.source_range
          end
        end

        def on_attr(node, attr_name, args)
          case attr_name
          when :attr
            writable = args.size == 2 && args.last.true_type?
            found_attr(node, [args.first], readable: true, writable: writable)
          when :attr_reader
            found_attr(node, args, readable: true)
          when :attr_writer
            found_attr(node, args, writable: true)
          when :attr_accessor
            found_attr(node, args, readable: true, writable: true)
          end
        end

        def found_attr(node, args, readable: false, writable: false)
          args.each do |arg|
            name = sym_name(arg)
            next unless name

            found_instance_method(node, name) if readable
            found_instance_method(node, "#{name}=") if writable
          end
        end

        def lookup_constant(node, const_name)
          # this method is quite imperfect and can be fooled
          # to do much better, we would need to do global analysis of the whole
          # codebase
          node.each_ancestor(:class, :module, :casgn) do |ancestor|
            namespace, mod_name = *ancestor.defined_module
            loop do
              if mod_name == const_name
                return qualified_name(ancestor.parent_module_name, namespace, mod_name)
              end

              break if namespace.nil?

              namespace, mod_name = *namespace
            end
          end
        end

        def qualified_name(enclosing, namespace, mod_name)
          if enclosing != 'Object'
            if namespace
              "#{enclosing}::#{namespace.const_name}::#{mod_name}"
            else
              "#{enclosing}::#{mod_name}"
            end
          elsif namespace
            "#{namespace.const_name}::#{mod_name}"
          else
            mod_name
          end
        end

        def source_location(node)
          range = node.source_range
          path = smart_path(range.source_buffer.name)
          "#{path}:#{range.line}"
        end

        def check_cross_file_duplicate(node, method_name)
          return unless project_index
          return if @self_aliased.include?(method_name)
          return if node.each_ancestor(:any_def).any?
          return unless (prior = cross_file_prior_definition(method_name))

          message = format(MSG, method: method_name,
                                defined: index_source_location(prior),
                                current: source_location(node))
          add_offense(location(node), message: message)
        end

        def cross_file_prior_definition(method_name)
          return unless (match = INDEXABLE_METHOD_NAME.match(method_name))

          definitions = definitions_in_other_files(
            indexed_definitions(match[:owner], match[:separator], match[:name])
          )
          return if definitions.empty? || cross_file_self_alias_trick?(definitions)

          first_indexed_definition(definitions)
        end

        def indexed_definitions(owner, separator, name)
          namespace = separator == '.' ? "#{owner}::<#{owner.split('::').last}>" : owner

          if name.match?(/\A\w+=\z/)
            # Rubydex indexes `attr_writer :foo` under `foo` rather than `foo=`, so
            # writer definitions come from both the `foo=` and the `foo` declarations.
            indexed_declaration_definitions(namespace, name) +
              indexed_declaration_definitions(namespace, name.delete_suffix('='))
              .select { |definition| writer_attr_definition?(definition) }
          else
            indexed_declaration_definitions(namespace, name).grep_v(Rubydex::AttrWriterDefinition)
          end
        end

        def indexed_declaration_definitions(namespace, name)
          project_index["#{namespace}##{name}()"]&.definitions.to_a
        end

        def writer_attr_definition?(definition)
          definition.is_a?(Rubydex::AttrWriterDefinition) ||
            definition.is_a?(Rubydex::AttrAccessorDefinition)
        end

        # An alias of the method alongside one of its definitions in another file may be
        # the self-alias trick marking an intentional redefinition there, so no offense
        # is registered. A genuine `alias` duplicate is still reported when the alias
        # itself is inspected.
        def cross_file_self_alias_trick?(definitions)
          aliases, others = definitions.partition do |definition|
            definition.is_a?(Rubydex::MethodAliasDefinition)
          end
          alias_paths = aliases.map { |definition| definition.location.to_file_path }

          others.any? { |definition| alias_paths.include?(definition.location.to_file_path) }
        end

        def first_indexed_definition(definitions)
          definitions.find { |definition| !definition.is_a?(Rubydex::MethodAliasDefinition) }
        end

        def index_source_location(definition)
          location = definition.location
          "#{smart_path(location.to_file_path)}:#{location.to_display.start_line}"
        end

        # Internal identity for an anonymous block, used as a scope key.
        # Includes the source range's begin position to distinguish blocks
        # that share the same line (e.g. two Class.new calls separated by `;`).
        # The user-facing offense message still uses `source_location`, which
        # shows only `path:line`.
        def anon_block_identity(anon_block)
          range = anon_block.source_range
          "#{smart_path(range.source_buffer.name)}:#{range.line}:#{range.begin_pos}"
        end
      end
    end
  end
end
