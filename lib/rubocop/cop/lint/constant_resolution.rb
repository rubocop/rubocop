# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks that certain constants are fully qualified.
      #
      # This is not enabled by default because it would mark a lot of offenses
      # unnecessarily.
      #
      # Generally, gems should fully qualify all constants to avoid conflicts with
      # the code that uses the gem. Enable this cop without using `Only`/`Ignore`
      #
      # Large projects will over time end up with one or two constant names that
      # are problematic because of a conflict with a library or just internally
      # using the same name for a namespace and a class. To avoid too many unnecessary
      # offenses, enable this cop with `Only: [The, Constant, Names, Causing, Issues]`
      #
      # NOTE: `Style/RedundantConstantBase` cop is disabled if this cop is enabled,
      # to prevent conflicting rules. This is because it respects user configurations
      # that want to enable this cop which is disabled by default.
      #
      # When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is
      # installed, only genuinely ambiguous constants are reported: those
      # that resolve to a different declaration through the surrounding
      # nesting than they would fully qualified. This makes the cop practical
      # to enable without `Only`/`Ignore` lists.
      #
      # @example
      #   # By default checks every constant
      #
      #   # bad
      #   User
      #
      #   # bad
      #   User::Login
      #
      #   # good
      #   ::User
      #
      #   # good
      #   ::User::Login
      #
      # @example Only: ['Login']
      #   # Restrict this cop to only being concerned about certain constants
      #
      #   # bad
      #   Login
      #
      #   # good
      #   ::Login
      #
      #   # good
      #   User::Login
      #
      # @example Ignore: ['Login']
      #   # Restrict this cop not being concerned about certain constants
      #
      #   # bad
      #   User
      #
      #   # good
      #   ::User::Login
      #
      #   # good
      #   Login
      #
      class ConstantResolution < Base
        include ProjectIndexHelp

        MSG = 'Fully qualify this constant to avoid possibly ambiguous resolution.'

        # @!method unqualified_const?(node)
        def_node_matcher :unqualified_const?, <<~PATTERN
          (const nil? #const_name?)
        PATTERN

        def on_const(node)
          return if !unqualified_const?(node) || node.parent&.defined_module || node.loc.nil?
          return if project_index && !ambiguous_resolution?(node)

          add_offense(node)
        end

        private

        # When `AllCops/UseProjectIndex` is enabled, only genuinely ambiguous
        # references are reported: the constant resolves to a different
        # declaration through the lexical nesting than it would fully
        # qualified. Names that resolve identically either way, or that the
        # index cannot resolve at all (e.g. constants from gems), are not
        # reported.
        def ambiguous_resolution?(node)
          relative = project_index.resolve_constant(node.short_name.to_s, lexical_nesting(node))
          absolute = project_index.resolve_constant(node.short_name.to_s, [])

          !relative.nil? && !absolute.nil? && relative.name != absolute.name
        rescue StandardError
          false
        end

        def lexical_nesting(node)
          scopes = node.each_ancestor(:class, :module).reject do |ancestor|
            in_superclass_expression?(node, ancestor)
          end

          scopes.map { |ancestor| ancestor.identifier.const_name }.reverse
        end

        # A constant in the superclass expression resolves in the scopes
        # enclosing the class definition, not inside it.
        def in_superclass_expression?(node, ancestor)
          ancestor.class_type? &&
            ancestor.parent_class&.each_descendant(:const)
                    &.any? { |descendant| descendant.equal?(node) }
        end

        def const_name?(name)
          name = name.to_s
          (allowed_names.empty? || allowed_names.include?(name)) && !ignored_names.include?(name)
        end

        def allowed_names
          cop_config['Only']
        end

        def ignored_names
          cop_config['Ignore']
        end
      end
    end
  end
end
