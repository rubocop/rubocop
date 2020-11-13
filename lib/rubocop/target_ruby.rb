# frozen_string_literal: true

module RuboCop
  # The kind of Ruby that code inspected by RuboCop is written in.
  # @api private
  class TargetRuby
    KNOWN_RUBIES = [2.4, 2.5, 2.6, 2.7, 3.0].freeze
    DEFAULT_VERSION = KNOWN_RUBIES.first

    OBSOLETE_RUBIES = {
      1.9 => '0.41', 2.0 => '0.50', 2.1 => '0.57', 2.2 => '0.68', 2.3 => '0.81'
    }.freeze
    private_constant :KNOWN_RUBIES, :OBSOLETE_RUBIES

    # A place where information about a target ruby version is found.
    # @api private
    class Source
      attr_reader :version, :name

      def initialize(config)
        @config = config
        @version = find_version
      end

      def to_s
        name
      end
    end

    # The target ruby version may be configured in RuboCop's config.
    # @api private
    class RuboCopConfig < Source
      def name
        "`TargetRubyVersion` parameter (in #{@config.smart_loaded_path})"
      end

      private

      def find_version
        @config.for_all_cops['TargetRubyVersion']&.to_f
      end
    end

    # The target ruby version may be found in a .ruby-version file.
    # @api private
    class RubyVersionFile < Source
      FILENAME = '.ruby-version'

      def name
        "`#{FILENAME}`"
      end

      private

      def find_version
        file = ruby_version_file
        return unless file && File.file?(file)

        # rubocop:disable Lint/MixedRegexpCaptureTypes
        # `(ruby-)` is not a capture type.
        File.read(file).match(/\A(ruby-)?(?<version>\d+\.\d+)/) do |md|
          # rubocop:enable Lint/MixedRegexpCaptureTypes
          md[:version].to_f
        end
      end

      def ruby_version_file
        @ruby_version_file ||=
          @config.find_file_upwards(FILENAME,
                                    @config.base_dir_for_path_parameters)
      end
    end

    # The lock file of Bundler may identify the target ruby version.
    # @api private
    class BundlerLockFile < Source
      def name
        "`#{bundler_lock_file_path}`"
      end

      private

      def find_version
        lock_file_path = bundler_lock_file_path
        return nil unless lock_file_path

        in_ruby_section = false
        File.foreach(lock_file_path) do |line|
          # If ruby is in Gemfile.lock or gems.lock, there should be two lines
          # towards the bottom of the file that look like:
          #     RUBY VERSION
          #       ruby W.X.YpZ
          # We ultimately want to match the "ruby W.X.Y.pZ" line, but there's
          # extra logic to make sure we only start looking once we've seen the
          # "RUBY VERSION" line.
          in_ruby_section ||= line.match(/^\s*RUBY\s*VERSION\s*$/)
          next unless in_ruby_section

          # We currently only allow this feature to work with MRI ruby. If
          # jruby (or something else) is used by the project, it's lock file
          # will have a line that looks like:
          #     RUBY VERSION
          #       ruby W.X.YpZ (jruby x.x.x.x)
          # The regex won't match in this situation.
          result = line.match(/^\s*ruby\s+(\d+\.\d+)[p.\d]*\s*$/)
          return result.captures.first.to_f if result
        end
      end

      def bundler_lock_file_path
        @config.bundler_lock_file_path
      end
    end

    # The target ruby version may be found in a .gemspec file.
    # @api private
    class GemspecFile < Source
      extend NodePattern::Macros

      GEMSPEC_EXTENSION = '.gemspec'

      def_node_search :required_ruby_version, <<~PATTERN
        (send _ :required_ruby_version= $_)
      PATTERN

      def_node_matcher :gem_requirement?, <<~PATTERN
        (send (const(const _ :Gem):Requirement) :new $str)
      PATTERN

      def name
        "`required_ruby_version` parameter (in #{gemspec_filename})"
      end

      private

      def find_version
        file = gemspec_filepath
        return unless file && File.file?(file)

        version = version_from_gemspec_file(file)
        return if version.nil?

        requirement = version.children.last
        return version_from_array(version) if version.array_type?
        return version_from_array(requirement) if gem_requirement? version

        version_from_str(version.str_content)
      end

      def gemspec_filename
        @gemspec_filename ||= begin
          basename = Pathname.new(@config.base_dir_for_path_parameters).basename.to_s
          "#{basename}#{GEMSPEC_EXTENSION}"
        end
      end

      def gemspec_filepath
        @gemspec_filepath ||=
          @config.find_file_upwards(gemspec_filename, @config.base_dir_for_path_parameters)
      end

      def version_from_gemspec_file(file)
        processed_source = ProcessedSource.from_file(file, DEFAULT_VERSION)
        required_ruby_version(processed_source.ast).first
      end

      def version_from_array(array)
        versions = array.children.map { |v| version_from_str(v.is_a?(String) ? v : v.str_content) }
        versions.compact.min
      end

      def version_from_str(str)
        str.match(/^(?:>=|<=)?\s*(?<version>\d+(?:\.\d+)*)/) do |md|
          md[:version].to_f
        end
      end
    end

    # If all else fails, a default version will be picked.
    # @api private
    class Default < Source
      def name
        'default'
      end

      private

      def find_version
        DEFAULT_VERSION
      end
    end

    def self.supported_versions
      KNOWN_RUBIES
    end

    SOURCES = [RuboCopConfig, RubyVersionFile, BundlerLockFile, GemspecFile, Default].freeze
    private_constant :SOURCES

    def initialize(config)
      @config = config
    end

    def source
      @source ||= SOURCES.each.lazy.map { |c| c.new(@config) }.detect(&:version)
    end

    def version
      source.version
    end

    def supported?
      KNOWN_RUBIES.include?(version)
    end

    def rubocop_version_with_support
      if supported?
        RuboCop::Version.version
      else
        OBSOLETE_RUBIES[version]
      end
    end
  end
end
