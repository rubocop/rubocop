# frozen_string_literal: true

module RuboCop
  module Cop
    # Error raised when an unqualified cop name is used that could
    # refer to two or more cops under different departments
    class AmbiguousCopName < RuboCop::Error
      MSG = 'Ambiguous cop name `%<name>s` used in %<origin>s needs ' \
            'department qualifier. Did you mean %<options>s?'.freeze

      def initialize(name, origin, badges)
        super(
          format(
            MSG,
            name: name,
            origin: origin,
            options: badges.to_a.join(' or ')
          )
        )
      end
    end

    # Registry that tracks all cops by their badge and department.
    class Registry
      def initialize(cops = [])
        @registry    = {}
        @departments = {}

        cops.each { |cop| enlist(cop) }
      end

      def enlist(cop)
        @registry[cop.badge] = cop
        @departments[cop.department] ||= []
        @departments[cop.department] << cop
      end

      # @return [Array<Symbol>] list of departments for current cops.
      def departments
        @departments.keys
      end

      # @return [Registry] Cops for that specific department.
      def with_department(department)
        with(@departments.fetch(department, []))
      end

      # @return [Registry] Cops not for a specific department.
      def without_department(department)
        without_department = @departments.dup
        without_department.delete(department)

        with(without_department.values.flatten)
      end

      def contains_cop_matching?(names)
        cops.any? { |cop| cop.match?(names) }
      end

      # Convert a user provided cop name into a properly namespaced name
      #
      # @example gives back a correctly qualified cop name
      #
      #   cops = RuboCop::Cop::Cop.all
      #   cops.qualified_cop_name('Style/IndentArray') # => 'Style/IndentArray'
      #
      # @example fixes incorrect namespaces
      #
      #   cops = RuboCop::Cop::Cop.all
      #   cops.qualified_cop_name('Lint/IndentArray') # => 'Style/IndentArray'
      #
      # @example namespaces bare cop identifiers
      #
      #   cops = RuboCop::Cop::Cop.all
      #   cops.qualified_cop_name('IndentArray') # => 'Style/IndentArray'
      #
      # @example passes back unrecognized cop names
      #
      #   cops = RuboCop::Cop::Cop.all
      #   cops.qualified_cop_name('NotACop') # => 'NotACop'
      #
      # @param name [String] Cop name extracted from config
      # @param path [String, nil] Path of file that `name` was extracted from
      #
      # @raise [AmbiguousCopName]
      #   if a bare identifier with two possible namespaces is provided
      #
      # @note Emits a warning if the provided name has an incorrect namespace
      #
      # @return [String] Qualified cop name
      def qualified_cop_name(name, path)
        badge = Badge.parse(name)
        return name if registered?(badge)

        potential_badges = qualify_badge(badge)

        case potential_badges.size
        when 0 then name # No namespace found. Deal with it later in caller.
        when 1 then resolve_badge(badge, potential_badges.first, path)
        else raise AmbiguousCopName.new(badge, path, potential_badges)
        end
      end

      def to_h
        cops.group_by(&:cop_name)
      end

      def cops
        @registry.values
      end

      def length
        @registry.size
      end

      def enabled(config, only)
        select do |cop|
          config.for_cop(cop).fetch('Enabled') || only.include?(cop.cop_name)
        end
      end

      def names
        cops.map(&:cop_name)
      end

      def ==(other)
        cops == other.cops
      end

      def sort!
        @registry = Hash[@registry.sort_by { |badge, _| badge.cop_name }]

        self
      end

      def select(&block)
        cops.select(&block)
      end

      def each(&block)
        cops.each(&block)
      end

      private

      def with(cops)
        self.class.new(cops)
      end

      def qualify_badge(badge)
        @departments
          .map { |department, _| badge.with_department(department) }
          .select { |potential_badge| registered?(potential_badge) }
      end

      def resolve_badge(given_badge, real_badge, source_path)
        unless given_badge.match?(real_badge)
          warn "#{source_path}: #{given_badge} has the wrong namespace - " \
               "should be #{real_badge.department}"
        end

        real_badge.to_s
      end

      def registered?(badge)
        @registry.key?(badge)
      end
    end
  end
end
