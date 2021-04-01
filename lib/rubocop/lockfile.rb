# frozen_string_literal: true

module RuboCop
  # Encapsulation of a lockfile for use when checking for gems.
  # Does not actually resolve gems, just parses the lockfile.
  # @api private
  class Lockfile
    # Gems that the bundle depends on
    def dependencies
      return [] unless parser

      parser.dependencies.values
    end

    # All activated gems, including transitive dependencies
    def gems
      return [] unless parser

      # `Bundler::LockfileParser` returns `Bundler::LazySpecification` objects
      # which are not resolved, so extract the dependencies from them
      parser.dependencies.values.concat(parser.specs.flat_map(&:dependencies))
    end

    def includes_gem?(name)
      gems.any? { |gem| gem.name == name }
    end

    private

    def parser
      return unless defined?(Bundler) && Bundler.default_lockfile
      return @parser if defined?(@parser)

      lockfile = Bundler.read_file(Bundler.default_lockfile)
      @parser = lockfile ? Bundler::LockfileParser.new(lockfile) : nil
    rescue Bundler::BundlerError
      nil
    end
  end
end
