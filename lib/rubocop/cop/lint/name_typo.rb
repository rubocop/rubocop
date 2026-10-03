# frozen_string_literal: true

begin
  require 'did_you_mean'
rescue LoadError
  nil
end

# Ruby's own core signatures, used to recognize the methods the interpreter
# provides. Shipped with Ruby as a bundled gem; without it those names are
# simply not recognized.
begin
  require 'rbs'
rescue LoadError
  nil
end

module RuboCop
  module Cop
    module Lint
      # Checks for probable typos in constant and method names: a name that
      # does not resolve anywhere in the project, used in a namespace the
      # project does define, with a close-named sibling to suggest instead.
      #
      # The check is powered by the project-wide index, so it only runs when
      # `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed.
      # Without the index the cop does nothing.
      #
      # Methods the interpreter itself provides are in no source index, since
      # they are implemented in C or compiled in: `Time.now` and `Regexp.new`,
      # and everything a constant naming a class or module inherits from
      # `Class`/`Module`, `Object` and `Kernel`. Those are recognized from the
      # RBS core signatures, which describe the language rather than RuboCop's
      # own process. That reads the `rbs` gem -- shipped with Ruby, but as a
      # bundled gem rather than a default one, so it has to be in the bundle to
      # be loadable. Without it such names can be reported as typos.
      #
      # Constants are checked only in qualified references (`Foo::Bar`) whose
      # namespace resolves in the index; bare names cannot be distinguished
      # from constants provided by gems or the standard library. Methods are
      # checked only in calls on constant receivers (`Foo.bar`) whose entire
      # indexed ancestry is resolved, so methods gained through gem classes or
      # dynamic definitions never produce offenses. In both cases an offense
      # requires a similarly named alternative to exist — an unknown name
      # alone is not reported, since the index does not see gems or the
      # standard library.
      #
      # For the same reason, a namespace whose root segment names a gem in the
      # bundle (`Flipper` for the `flipper` gem) is left alone: a project that
      # reopens it (`module Flipper; module Adapters; ...`) makes it resolve in
      # the index, while the members the gem itself defines stay invisible and
      # would look like typos. Enabling `AllCops/ProjectIndexIncludesGems`
      # indexes those sources and restores the check.
      #
      # Names that appear as symbols or inside string literals in the same
      # file are never reported, since they usually belong to runtime
      # definitions the index cannot see (`stub_const`, `const_set`,
      # `define_method`, and the like).
      #
      # @example
      #   # bad - Services::UserCraetor is not defined, Services::UserCreator is
      #   Services::UserCraetor.new
      #
      #   # good
      #   Services::UserCreator.new
      #
      #   # bad - Report.generate_sumary is not defined, Report.generate_summary is
      #   Report.generate_sumary
      #
      #   # good
      #   Report.generate_summary
      #
      # @example CheckConstants: false
      #   # good - constant references are not checked
      #   Services::UserCraetor.new
      #
      # @example CheckMethods: false
      #   # good - method calls are not checked
      #   Report.generate_sumary
      #
      # @example AllowedNames: ['generate_sumary']
      #   # good - the name is explicitly allowed
      #   Report.generate_sumary
      #
      class NameTypo < Base
        include ProjectIndexHelp

        CONSTANT_MSG = 'Possible typo: `%<name>s` is not defined in `%<namespace>s`. ' \
                       'Did you mean `%<suggestion>s`?'
        METHOD_MSG = 'Possible typo: `%<receiver>s` does not respond to `%<name>s`. ' \
                     'Did you mean `%<suggestion>s`?'

        METHOD_MEMBER_REGEXP = /#([a-zA-Z_]\w*[?!]?)\(\)\z/.freeze
        LITERAL_IDENTIFIER_PATTERN = /[a-zA-Z_]\w*[?!]?/.freeze
        # Ruby's own methods, read from the RBS core signatures that ship with
        # the `rbs` gem. This is static, versioned data describing the Ruby
        # being targeted, not a reflection of RuboCop's own process, so the
        # answer does not change with what RuboCop happens to have loaded.
        #
        # Nothing is loaded until the first query, and only `core` is read --
        # never a stdlib or gem signature -- so the vocabulary is exactly what
        # the interpreter itself provides.
        module CoreSignatures
          class << self
            # Whether Ruby's core gives the named class or module a singleton
            # method by one of these names. Always false for a name core does
            # not declare, which includes every class a project defines itself.
            def singleton_method?(namespace, names)
              type_name = core_type_names[qualified(namespace)]

              type_name ? any_method?(type_name, :singleton, names) : false
            end

            # Whether a bare class or module object answers to one of these
            # names, as every constant naming one does. Asked by kind, since
            # `Module` has no `superclass` and `Formatting.superclass` is
            # therefore a real offense.
            def object_method?(kind, names)
              type_name = core_type_names[kind == :class ? '::Class' : '::Module']

              type_name ? any_method?(type_name, :instance, names) : false
            end

            private

            def any_method?(type_name, kind, names)
              methods = methods_for(type_name, kind)

              methods ? names.any? { |name| methods.include?(name.to_sym) } : false
            end

            def methods_for(type_name, kind)
              key = [type_name.to_s, kind]
              method_cache.fetch(key) do
                method_cache[key] = build_methods(type_name, kind)
              end
            end

            def build_methods(type_name, kind)
              definition = if kind == :singleton
                             builder.build_singleton(type_name)
                           else
                             builder.build_instance(type_name)
                           end
              definition.methods.keys.to_set
            rescue StandardError
              nil
            end

            def method_cache
              @method_cache ||= {}
            end

            # Core type names by their fully qualified string, which sidesteps
            # constructing an `RBS::TypeName` and the API differences between
            # `rbs` versions in doing so.
            def core_type_names
              @core_type_names ||= begin
                env = environment
                env ? env.class_decls.keys.to_h { |type_name| [type_name.to_s, type_name] } : {}
              end
            end

            # Core declares every name at the root, so a namespace is looked up
            # fully qualified. A project's own `Foo::Bar` simply misses.
            def qualified(namespace)
              name = namespace.to_s
              name.start_with?('::') ? name : "::#{name}"
            end

            def builder
              @builder ||= RBS::DefinitionBuilder.new(env: environment)
            end

            # The core signatures alone: `EnvironmentLoader` with no library
            # asked for reads `core` and nothing else.
            def environment
              return @environment if defined?(@environment)

              @environment = begin
                RBS::Environment.from_loader(RBS::EnvironmentLoader.new).resolve_type_names
              rescue StandardError, LoadError
                nil
              end
            end
          end
        end

        def on_const(node)
          return unless check?('CheckConstants') && checkable_constant?(node)

          suggestion = constant_typo_suggestion(node)
          return unless suggestion

          message = format(CONSTANT_MSG, name: node.short_name,
                                         namespace: node.namespace.const_name,
                                         suggestion: suggestion)
          add_offense(node.loc.name, message: message)
        end

        def on_send(node)
          return unless check?('CheckMethods')
          return unless node.receiver&.const_type?
          return if allowed_name?(node.method_name) || defined_check?(node)

          suggestion = method_typo_suggestion(node)
          return unless suggestion

          message = format(METHOD_MSG, receiver: node.receiver.const_name,
                                       name: node.method_name,
                                       suggestion: suggestion)
          add_offense(node.loc.selector, message: message)
        end
        alias on_csend on_send

        def on_new_investigation
          @literal_names = nil
          super
        end

        private

        def check?(key)
          project_index && defined?(DidYouMean::SpellChecker) && cop_config.fetch(key, true)
        end

        def checkable_constant?(node)
          node.namespace&.const_type? &&
            !allowed_name?(node.short_name) &&
            !definition_identifier?(node) && !defined_check?(node)
        end

        def allowed_name?(name)
          cop_config.fetch('AllowedNames', []).include?(name.to_s)
        end

        # The last segment of a class, module or constant definition is being
        # defined, not referenced.
        def definition_identifier?(node)
          node.parent&.defined_module
        end

        # `defined?(Foo::Bar)` probes whether a name exists; unknown names
        # there are deliberate.
        def defined_check?(node)
          node.each_ancestor(:defined?).any?
        end

        def constant_typo_suggestion(node)
          namespace = resolve_constant_in_index(node.namespace)
          return nil unless namespace.is_a?(Rubydex::Namespace)
          return nil if namespace.find_member(node.short_name.to_s)
          return nil unless complete_index_members?(namespace)
          return nil if literal_names.include?(node.short_name.to_s)

          spell_check(node.short_name, constant_member_names(namespace))
        rescue StandardError
          nil
        end

        # Whether the index can be trusted to list everything the namespace
        # defines. A name missing from an incomplete member list is not
        # evidence of a typo, so both gaps have to be ruled out first:
        # an ancestor that does not resolve may contribute the name, and so
        # may a gem that reopens the namespace.
        def complete_index_members?(declaration)
          fully_resolved_index_ancestry?(declaration) && !gem_owned_namespace?(declaration)
        end

        # Whether the namespace's root segment names a gem in the bundle,
        # which is then free to define members the index never sees: gem
        # sources are only indexed when `AllCops/ProjectIndexIncludesGems`
        # is enabled. A project that reopens such a namespace to add its own
        # members (`module Flipper; module Adapters; ...`) makes it resolve
        # in the index while most of what it holds stays invisible.
        def gem_owned_namespace?(declaration)
          return false if config.for_all_cops['ProjectIndexIncludesGems']

          root = declaration.name.to_s.split('::').first.to_s
          bundled_gem_namespaces.include?(root.downcase)
        end

        # Gem names normalized towards the constant they conventionally
        # provide: `flipper` for `Flipper`, `activerecord` for `ActiveRecord`.
        def bundled_gem_namespaces
          @bundled_gem_namespaces ||= bundled_gem_names.to_set { |name| name.delete('-_').downcase }
        end

        # The bundle's gems except those sourced from a local path, whose code
        # lives in the project and is indexed like the rest of it — among them
        # the project's own gem, which its lockfile lists in the `PATH` section.
        def bundled_gem_names
          (config.gem_versions_in_target || {}).keys - (config.path_sourced_gems_in_target || [])
        end

        # Writers are indexed under the reader's name, so setter calls are
        # verified and spell-checked through the base name.
        def method_typo_suggestion(node)
          setter = setter_call?(node)
          base = setter ? node.method_name.to_s.delete_suffix('=') : node.method_name.to_s

          declaration = unknown_method_owner(node, base)
          return nil unless declaration
          return nil if literal_names.include?(base)

          suggestion = spell_check(base, method_member_names(declaration))
          suggestion && setter ? "#{suggestion}=" : suggestion
        rescue StandardError
          nil
        end

        # The receiver's declaration when it resolves in the index, everything
        # it can inherit or be reopened with is visible there, and the method
        # is not found — nil otherwise.
        def unknown_method_owner(node, base)
          declaration = resolve_constant_in_index(node.receiver)
          return nil unless declaration.is_a?(Rubydex::Namespace)
          return nil if responds_in_index?(declaration, node.method_name.to_s, base)
          return nil unless fully_resolved_index_ancestry?(declaration)
          return nil if gem_owned_namespace?(declaration)
          return nil if core_provided_method?(declaration, node.method_name.to_s, base)

          declaration
        end

        # Whether Ruby itself provides the method, in which case its absence
        # from the index is no evidence of a typo. There are two ways that
        # happens, and neither is visible to a source index because the
        # interpreter implements them in C or compiles them in.
        #
        # First, the namespace may be one Ruby provides. `Time` and `Regexp`
        # resolve in the index only because something indexed reopens them --
        # `ProjectIndexIncludesGems` makes that routine, since gems like
        # ActiveSupport reopen both -- and their ancestry resolves too, so
        # every other completeness guard passes and the handful of members the
        # reopening added become the whole dictionary. `Time.now` then looks
        # like a typo of `Time.noon`.
        #
        # Second, the constant may be any class or module at all. It is itself
        # an object, so it answers everything `Class`/`Module`, `Object` and
        # `Kernel` define -- `send`, `to_s`, `freeze` and the rest. That covers
        # a project's own classes, which the first case does not, since core
        # does not declare them: `Bar.send` was reported as a typo of
        # `Bar.send_pm`.
        #
        # Only names core actually declares are skipped, so a genuine typo is
        # still reported. Methods a stdlib library adds (`Time.rfc2822`) are
        # equally invisible to the index and stay uncovered: whether the
        # analyzed project requires that library is not something the core
        # signatures can say.
        def core_provided_method?(declaration, name, base)
          return false unless defined?(RBS)

          candidates = [name, base].uniq
          kind = declaration.is_a?(Rubydex::Class) ? :class : :module

          CoreSignatures.object_method?(kind, candidates) ||
            CoreSignatures.singleton_method?(declaration.name, candidates)
        rescue StandardError
          false
        end

        def setter_call?(node)
          node.assignment_method? && !node.operator_method?
        end

        def responds_in_index?(declaration, name, base)
          # Instance methods of a module are also callable on the module
          # itself when exposed with `module_function`.
          [name, base].uniq.any? do |candidate|
            member_name = "#{candidate}()"
            indexed_singleton_member(declaration, member_name) ||
              declaration.find_member(member_name)
          end
        end

        # Names mentioned as symbols or inside string literals in the current
        # file belong to runtime definitions (`stub_const`, `const_set`,
        # `define_method`) that the index cannot see.
        def literal_names
          @literal_names ||=
            processed_source.ast.each_descendant(:sym, :str)
                            .with_object(Set.new) do |literal, names|
              if literal.sym_type?
                names << literal.value.to_s
              else
                # `scan` raises on binary string literals with invalid byte sequences.
                value = literal.value
                value = value.scrub unless value.valid_encoding?
                value.scan(LITERAL_IDENTIFIER_PATTERN) { |token| names << token }
              end
            end
        end

        def constant_member_names(namespace)
          namespace.members.filter_map do |member|
            name = member.name
            name.split('::').last unless name.include?('#') || name.include?('<')
          end
        end

        def method_member_names(declaration)
          scopes = declaration.ancestors.filter_map { |ancestor| indexed_singleton_of(ancestor) }
          scopes << declaration

          scopes.flat_map do |scope|
            scope.members.filter_map { |member| member.name[METHOD_MEMBER_REGEXP, 1] }
          end
        end

        def spell_check(name, dictionary)
          return nil if dictionary.empty?

          DidYouMean::SpellChecker.new(dictionary: dictionary.uniq).correct(name.to_s).first
        end
      end
    end
  end
end
