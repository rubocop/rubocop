# frozen_string_literal: true

module RuboCop
  # The kind of Ruby that code inspected by RuboCop is written in.
  # @api private
  class TargetRuby
    KNOWN_RUBIES = [2.6, 2.7, 3.0, 3.1, 3.2].freeze
    DEFAULT_VERSION = KNOWN_RUBIES.first

    OBSOLETE_RUBIES = {
      1.9 => '0.41',
      2.0 => '0.50',
      2.1 => '0.57',
      2.2 => '0.68',
      2.3 => '0.81',
      2.4 => '1.12',
      2.5 => '1.28'
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
      RUBY_VERSION_FILENAME = '.ruby-version'
      RUBY_VERSION_PATTERN = /\A(?:ruby-)?(?<version>\d+\.\d+)/.freeze

      def name
        "`#{RUBY_VERSION_FILENAME}`"
      end

      private

      def filename
        RUBY_VERSION_FILENAME
      end

      def pattern
        RUBY_VERSION_PATTERN
      end

      def find_version
        file = version_file
        return unless file && File.file?(file)

        File.read(file).match(pattern) { |md| md[:version].to_f }
      end

      def version_file
        @version_file ||= @config.find_file_upwards(filename, @config.base_dir_for_path_parameters)
      end
    end

    # The target ruby version may be found in a .tool-versions file, in a line
    # starting with `ruby`.
    # @api private
    class ToolVersionsFile < RubyVersionFile
      TOOL_VERSIONS_FILENAME = '.tool-versions'
      TOOL_VERSIONS_PATTERN = /\Aruby (?:ruby-)?(?<version>\d+\.\d+)/.freeze

      def name
        "`#{TOOL_VERSIONS_FILENAME}`"
      end

      private

      def filename
        TOOL_VERSIONS_FILENAME
      end

      def pattern
        TOOL_VERSIONS_PATTERN
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

      # @!method required_ruby_version(node)
      def_node_search :required_ruby_version, <<~PATTERN
        (send _ :required_ruby_version= $_)
      PATTERN

      # @!method gem_requirement?(node)
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

        right_hand_side = version_from_gemspec_file(file)
        return if right_hand_side.nil?

        find_minimal_known_ruby(right_hand_side)
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

      def version_from_right_hand_side(right_hand_side)
        if right_hand_side.array_type?
          version_from_array(right_hand_side)
        elsif gem_requirement?(right_hand_side)
          right_hand_side.children.last.value
        else
          right_hand_side.value
        end
      end

      def version_from_array(array)
        array.children.map(&:value)
      end

      def find_minimal_known_ruby(right_hand_side)
        version = version_from_right_hand_side(right_hand_side)
        requirement = Gem::Requirement.new(version)

        KNOWN_RUBIES.detect { |v| requirement.satisfied_by?(Gem::Version.new("#{v}.99")) }
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

    SOURCES = [
      RuboCopConfig,
      RubyVersionFile,
      ToolVersionsFile,
      BundlerLockFile,
      GemspecFile,
      Default
    ].freeze

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
