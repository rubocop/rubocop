# frozen_string_literal: true

begin
  require 'did_you_mean'
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
          return nil if literal_names.include?(node.short_name.to_s)

          namespace = resolve_constant_in_index(node.namespace)
          return nil unless namespace.is_a?(Rubydex::Namespace)
          return nil if namespace.find_member(node.short_name.to_s)

          spell_check(node.short_name, constant_member_names(namespace))
        rescue StandardError
          nil
        end

        # Writers are indexed under the reader's name, so setter calls are
        # verified and spell-checked through the base name.
        def method_typo_suggestion(node)
          setter = setter_call?(node)
          base = setter ? node.method_name.to_s.delete_suffix('=') : node.method_name.to_s
          return nil if literal_names.include?(base)

          declaration = unknown_method_owner(node, base)
          return nil unless declaration

          suggestion = spell_check(base, method_member_names(declaration))
          suggestion && setter ? "#{suggestion}=" : suggestion
        rescue StandardError
          nil
        end

        # The receiver's declaration when it resolves in the index, its whole
        # ancestry is resolved, and the method is not found — nil otherwise.
        def unknown_method_owner(node, base)
          declaration = resolve_constant_in_index(node.receiver)
          return nil unless declaration.is_a?(Rubydex::Namespace)
          return nil if responds_in_index?(declaration, node.method_name.to_s, base)
          return nil unless fully_resolved_index_ancestry?(declaration)

          declaration
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
                literal.value.scan(LITERAL_IDENTIFIER_PATTERN) { |token| names << token }
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
