# frozen_string_literal: true

module RuboCop
  module Cop
    # Error raised when an unqualified cop name is used that could
    # refer to two or more cops under different departments
    class AmbiguousCopName < RuboCop::Error
      MSG = 'Ambiguous cop name `%<name>s` used in %<origin>s needs ' \
            'department qualifier. Did you mean %<options>s?'

      def initialize(name, origin, badges)
        super(
          format(MSG, name: name, origin: origin, options: badges.to_a.join(' or '))
        )
      end
    end

    # Registry that tracks all cops by their badge and department.
    class Registry # rubocop:disable Metrics/ClassLength
      include Enumerable

      def self.all
        global.without_department(:Test).cops
      end

      def self.qualified_cop_name(name, origin, warn: true)
        global.qualified_cop_name(name, origin, warn: warn)
      end

      # Changes momentarily the global registry
      # Intended for testing purposes
      def self.with_temporary_global(temp_global = global.dup)
        previous = @global
        @global = temp_global
        yield
      ensure
        @global = previous
      end

      def self.reset!
        @global = new
      end

      def self.qualified_cop?(name)
        badge = Badge.parse(name)
        global.qualify_badge(badge).first == badge
      end

      attr_reader :options, :warnings

      def initialize(cops = [], options = {})
        @departments = Set.new
        # Maps each badge to its cop class, or to the fully qualified constant name (a `String`)
        # when the cop is registered for lazy loading and its file is not loaded yet.
        # A single insertion-ordered map keeps the registration order stable no matter when
        # a lazy-loaded cop's file gets loaded, because reassigning an existing key preserves
        # its position; the cop execution order depends on this order.
        @cops_by_badge = {}

        @enrollment_queue = cops
        @options = options

        @enabled_cache = {}.compare_by_identity
        @disabled_cache = {}.compare_by_identity
        @disabled_names_cache = {}.compare_by_identity
        @warnings = {}
      end

      # Registers a cop by its badge and constant name without loading the class.
      # The constant is resolved (loading the cop's file through `autoload`) only
      # when the cop class itself is needed.
      #
      # @param badge [Badge, String] the badge, or the qualified cop name
      # @param constant_name [String] the fully qualified constant name
      def lazy_load(badge, constant_name)
        badge = Badge.parse(badge) if badge.is_a?(String)

        # File any cops enlisted earlier first, so that the registration
        # order follows the call order.
        clear_enrollment_queue

        @departments << badge.department
        @cops_by_badge[badge] = constant_name unless @cops_by_badge[badge].is_a?(Class)
      end

      def enlist(cop)
        @enrollment_queue << cop
      end

      def dismiss(cop)
        dismissed = !@enrollment_queue.delete(cop).nil?

        # A lazy-loaded cop that was not enlisted yet is dismissed by removing its registration.
        # Anonymous cop classes cannot have a badge.
        if !cop.name.nil? && @cops_by_badge[cop.badge].is_a?(String)
          @cops_by_badge.delete(cop.badge)
          dismissed = true
        end

        raise "Cop #{cop} could not be dismissed" unless dismissed
      end

      # @return [Array<Symbol>] list of departments for current cops.
      def departments
        clear_enrollment_queue
        @departments.to_a
      end

      # @return [Registry] Cops for that specific department.
      def with_department(department)
        filter_by_badge { |badge| badge.department == department }
      end

      # @return [Registry] Cops not for a specific department.
      def without_department(department)
        filter_by_badge { |badge| badge.department != department }
      end

      # Returns a new registry containing the cops whose badge satisfies the given block,
      # keeping lazy-loaded cops unloaded.
      #
      # @api private
      # @return [Registry]
      def filter_by_badge(options = {})
        clear_enrollment_queue
        copy = self.class.new([], options)
        @cops_by_badge.each do |badge, cop_or_name|
          copy.add_entry(badge, cop_or_name) if yield(badge)
        end
        copy
      end

      # @return [Boolean] Checks if given name is department
      def department?(name)
        departments.include?(name.to_sym)
      end

      def contains_cop_matching?(names)
        registered_badges.any? { |badge| badge.match_name?(names) }
      end

      # Convert a user provided cop name into a properly namespaced name
      #
      # @example gives back a correctly qualified cop name
      #
      #   registry = RuboCop::Cop::Registry
      #   registry.qualified_cop_name('Layout/EndOfLine', '') # => 'Layout/EndOfLine'
      #
      # @example fixes incorrect namespaces
      #
      #   registry = RuboCop::Cop::Registry
      #   registry.qualified_cop_name('Lint/EndOfLine', '') # => 'Layout/EndOfLine'
      #
      # @example namespaces bare cop identifiers
      #
      #   registry = RuboCop::Cop::Registry
      #   registry.qualified_cop_name('EndOfLine', '') # => 'Layout/EndOfLine'
      #
      # @example passes back unrecognized cop names
      #
      #   registry = RuboCop::Cop::Registry
      #   registry.qualified_cop_name('NotACop', '') # => 'NotACop'
      #
      # @param name [String] Cop name extracted from config
      # @param path [String, nil] Path of file that `name` was extracted from
      # @param warn [Boolean] Print a warning if no department given for `name`
      #
      # @raise [AmbiguousCopName]
      #   if a bare identifier with two possible namespaces is provided
      #
      # @note Emits a warning if the provided name has an incorrect namespace
      #
      # @return [String] Qualified cop name
      def qualified_cop_name(name, path, warn: true)
        badge = Badge.parse(name)
        print_department_missing_warning(name, path) if warn && department_missing?(badge, name)
        return name if registered?(badge)

        potential_badges = qualify_badge(badge)

        case potential_badges.size
        when 0 then name # No namespace found. Deal with it later in caller.
        when 1 then resolve_badge(badge, potential_badges.first, path, warn: warn)
        else raise AmbiguousCopName.new(badge, path, potential_badges)
        end
      end

      def department_missing?(badge, name)
        !badge.qualified? && unqualified_cop_names.include?(name)
      end

      def print_department_missing_warning(name, path)
        message = "no department given for #{name}."
        if path.end_with?('.rb')
          message += ' Run `rubocop -a --only Migration/DepartmentName` to fix.'
        end
        emit_warning(path, message)
      end

      def unqualified_cop_names
        clear_enrollment_queue

        @unqualified_cop_names ||= @cops_by_badge.keys.to_set do |badge|
          File.basename(badge.to_s)
        end << 'RedundantCopDisableDirective'
      end

      def qualify_badge(badge)
        clear_enrollment_queue
        @departments
          .map { |department| badge.with_department(department) }
          .select { |potential_badge| registered?(potential_badge) }
      end

      # @return [Hash{String => Array<Class>}]
      def to_h
        clear_enrollment_queue
        load_all_lazy_cops
        @cops_by_badge.to_h { |_badge, cop| [cop.cop_name, [cop]] }
      end

      def cops
        clear_enrollment_queue
        load_all_lazy_cops
        @cops_by_badge.values
      end

      def length
        clear_enrollment_queue
        @cops_by_badge.size
      end

      # Returns the enabled cop classes, loading lazy-loaded cops only when they are enabled.
      #
      # @return [Array<Class>]
      def enabled(config)
        @enabled_cache[config] ||= registered_badges.filter_map do |badge|
          next unless enabled_cop_name?(badge.to_s, config)

          cop_or_name = @cops_by_badge[badge]
          cop_or_name.is_a?(String) ? load_lazy_cop(badge) : cop_or_name
        end
      end

      def disabled(config)
        @disabled_cache[config] ||= reject { |cop| enabled?(cop, config) }
      end

      # Returns the names of the disabled cops without loading any of them.
      #
      # @api private
      # @return [Array<String>]
      def disabled_names(config)
        @disabled_names_cache[config] ||= registered_badges.filter_map do |badge|
          name = badge.to_s
          name unless enabled_cop_name?(name, config)
        end
      end

      def enabled?(cop, config)
        enabled_cop_name?(cop.cop_name, config)
      end

      # @param cop [Class, String, nil] the cop class or the qualified cop name
      def enabled_pending_cop?(cop_cfg, config, cop = nil)
        return false if @options[:disable_pending_cops]
        return false unless cop_cfg.fetch('Enabled') == 'pending'
        return true if @options[:enable_pending_cops]
        return config.enabled_new_cops? unless cop

        cop_name = cop.is_a?(String) ? cop : cop.cop_name
        config.enabled_new_cop?(cop_name)
      end

      def names
        clear_enrollment_queue
        @cops_by_badge.keys.map(&:to_s)
      end

      def cops_for_department(department)
        with_department(department.to_sym).cops
      end

      def names_for_department(department)
        department = department.to_sym

        registered_badges.filter_map { |badge| badge.to_s if badge.department == department }
      end

      def ==(other)
        cops == other.cops
      end

      def sort!
        clear_enrollment_queue
        load_all_lazy_cops
        @cops_by_badge = @cops_by_badge.sort_by { |badge, _cop| badge.cop_name }.to_h

        self
      end

      def select(&block)
        cops.select(&block)
      end

      def each(&block)
        cops.each(&block)
      end

      # @param [String] cop_name
      # @return [Class, nil]
      def find_by_cop_name(cop_name)
        clear_enrollment_queue
        badge = Badge.parse(cop_name)
        cop_or_name = @cops_by_badge[badge]

        cop_or_name.is_a?(String) ? load_lazy_cop(badge) : cop_or_name
      end

      # When a cop name is given returns a single-element array with the cop class.
      # When a department name is given returns an array with all the cop classes
      # for that department.
      def find_cops_by_directive(directive)
        cop = find_by_cop_name(directive)
        cop ? [cop] : cops_for_department(directive)
      end

      def freeze
        clear_enrollment_queue
        load_all_lazy_cops
        unqualified_cop_names # build cache
        super
      end

      @global = new

      class << self
        attr_reader :global
      end

      def warnings?(path)
        @warnings[path]
      end

      protected

      # Adds an already-loaded cop class or a lazy-load constant name under the given badge,
      # used to build filtered copies.
      def add_entry(badge, cop_or_name)
        @departments << badge.department
        @cops_by_badge[badge] = cop_or_name
      end

      private

      def initialize_copy(reg)
        super
        @cops_by_badge = @cops_by_badge.dup
        @enrollment_queue = @enrollment_queue.dup
        @departments = @departments.dup
        @enabled_cache = {}.compare_by_identity
        @disabled_cache = {}.compare_by_identity
        @disabled_names_cache = {}.compare_by_identity
        @warnings = {}
        @unqualified_cop_names = nil
      end

      def clear_enrollment_queue
        return if @enrollment_queue.empty?

        @enrollment_queue.each do |cop|
          # Reassigning a badge that was registered for lazy loading keeps
          # its original position in the insertion-ordered map.
          @cops_by_badge[cop.badge] = cop
          @departments << cop.department
        end
        @enrollment_queue = []
      end

      def registered_badges
        clear_enrollment_queue
        @cops_by_badge.keys
      end

      def enabled_cop_name?(cop_name, config)
        return true if options[:only]&.include?(cop_name)

        # We need to use the cop name in this case, because `for_cop` uses
        # caching which expects cop names or cop classes as keys.
        cfg = config.for_cop(cop_name)

        cop_enabled = cfg.fetch('Enabled') == true || enabled_pending_cop?(cfg, config, cop_name)

        if options.fetch(:safe, false)
          cop_enabled && cfg.fetch('Safe', true)
        else
          cop_enabled
        end
      end

      def load_all_lazy_cops
        # Take a snapshot because loading a cop can load (and thereby register)
        # another lazy-loaded cop, e.g. its superclass.
        badges = @cops_by_badge.keys
        badges.each { |badge| load_lazy_cop(badge) if @cops_by_badge[badge].is_a?(String) }
      end

      # @return [Class, nil] the loaded cop class, or nil if the cop excluded
      #   itself from the registry while being loaded
      def load_lazy_cop(badge)
        constant_name = @cops_by_badge[badge]
        return constant_name unless constant_name.is_a?(String)

        cop = Kernel.const_get(constant_name)
        if equal?(self.class.global)
          # Resolving the constant fires the autoload, which makes
          # `Base.inherited` enlist the class into the global registry.
          # Enrolling through the queue keeps `exclude_from_registry` honored:
          # a cop that dismissed itself leaves a dangling constant name behind
          # and is removed from the registry.
          clear_enrollment_queue
          cop_or_name = @cops_by_badge[badge]
          @cops_by_badge.delete(badge) if cop_or_name.is_a?(String)
          cop_or_name.is_a?(Class) ? cop_or_name : nil
        else
          # `Base.inherited` enlists into the global registry, not this copy.
          @cops_by_badge[badge] = cop
        end
      end

      def resolve_badge(given_badge, real_badge, source_path, warn: true)
        if warn && !given_badge.match?(real_badge)
          emit_warning(source_path,
                       "#{given_badge} has the wrong namespace - " \
                       "replace it with #{given_badge.with_department(real_badge.department)}")
        end

        real_badge.to_s
      end

      def emit_warning(path, message)
        Registry.global.warnings[path] = true
        warn "#{PathUtil.smart_path(path)}: Warning: #{message}"
      end

      def registered?(badge)
        clear_enrollment_queue
        @cops_by_badge.key?(badge)
      end
    end
  end
end
