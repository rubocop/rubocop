# frozen_string_literal: true

module RuboCop
  # Encapsulation of a lockfile for use when checking for gems.
  # Does not actually resolve gems, just parses the lockfile.
  # @api private
  class Lockfile
    # @param [String, Pathname, nil] lockfile_path
    def initialize(lockfile_path = nil)
      lockfile_path ||= defined?(Bundler) ? Bundler.default_lockfile : nil

      @lockfile_path = lockfile_path
    end

    # Gems that the bundle directly depends on.
    # @return [Array<Bundler::Dependency>, nil]
    def dependencies
      return [] unless parser

      parser.dependencies.values
    end

    # All activated gems, including transitive dependencies.
    # @return [Array<Bundler::Dependency>, nil]
    def gems
      return [] unless parser

      # `Bundler::LockfileParser` returns `Bundler::LazySpecification` objects
      # which are not resolved, so extract the dependencies from them
      parser.dependencies.values.concat(parser.specs.flat_map(&:dependencies))
    end

    # Whether this lockfile includes the named gem, directly or indirectly.
    # @param [String] name
    # @return [Boolean]
    def includes_gem?(name)
      gems.any? { |gem| gem.name == name }
    end

    private

    # @return [Bundler::LockfileParser, nil]
    def parser
      return @parser if defined?(@parser)
      return unless @lockfile_path

      lockfile = Bundler.read_file(@lockfile_path)
      @parser = lockfile ? Bundler::LockfileParser.new(lockfile) : nil
    rescue Bundler::BundlerError
      nil
    end
  end
end
