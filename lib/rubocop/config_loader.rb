# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'pathname'

module RuboCop
  # Raised when a RuboCop configuration file is not found.
  class ConfigNotFoundError < Error
  end

  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class ConfigLoader
    DOTFILE = '.rubocop.yml'
    XDG_CONFIG = 'config.yml'
    RUBOCOP_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(RUBOCOP_HOME, 'config', 'default.yml')

    class << self
      include FileFinder

      attr_accessor :debug, :ignore_parent_exclusion, :disable_pending_cops, :enable_pending_cops,
                    :ignore_unrecognized_cops
      attr_writer :default_configuration, :project_root
      attr_reader :loaded_features

      alias debug? debug
      alias ignore_parent_exclusion? ignore_parent_exclusion

      def clear_options
        @debug = nil
        @loaded_features = Set.new
        FileFinder.root_level = nil
      end

      def load_file(file, check: true)
        path = file_path(file)

        hash = load_yaml_configuration(path)

        # Resolve requires first in case they define additional cops
        loaded_features = resolver.resolve_requires(path, hash)
        add_loaded_features(loaded_features)

        add_missing_namespaces(path, hash)

        resolver.override_department_setting_for_cops({}, hash)
        resolver.resolve_inheritance_from_gems(hash)
        resolver.resolve_inheritance(path, hash, file, debug?)

        hash.delete('inherit_from')

        Config.create(hash, path, check: check)
      end

      def load_yaml_configuration(absolute_path)
        file_contents = read_file(absolute_path)
        yaml_code = Dir.chdir(File.dirname(absolute_path)) { ERB.new(file_contents).result }
        check_duplication(yaml_code, absolute_path)
        hash = yaml_safe_load(yaml_code, absolute_path) || {}

        puts "configuration from #{absolute_path}" if debug?

        raise(TypeError, "Malformed configuration in #{absolute_path}") unless hash.is_a?(Hash)

        hash
      end

      def add_missing_namespaces(path, hash)
        # Using `hash.each_key` will cause the
        # `can't add a new key into hash during iteration` error
        hash_keys = hash.keys
        hash_keys.each do |key|
          q = Cop::Registry.qualified_cop_name(key, path)
          next if q == key

          hash[q] = hash.delete(key)
        end
      end

      # Return a recursive merge of two hashes. That is, a normal hash merge,
      # with the addition that any value that is a hash, and occurs in both
      # arguments, will also be merged. And so on.
      def merge(base_hash, derived_hash)
        resolver.merge(base_hash, derived_hash)
      end

      # Returns the path of .rubocop.yml searching upwards in the
      # directory structure starting at the given directory where the
      # inspected file is. If no .rubocop.yml is found there, the
      # user's home directory is checked. If there's no .rubocop.yml
      # there either, the path to the default file is returned.
      def configuration_file_for(target_dir)
        find_project_dotfile(target_dir) || find_user_dotfile ||
          find_user_xdg_config || DEFAULT_FILE
      end

      def configuration_from_file(config_file, check: true)
        return default_configuration if config_file == DEFAULT_FILE

        config = load_file(config_file, check: check)
        config.validate_after_resolution if check

        if ignore_parent_exclusion?
          print 'Ignoring AllCops/Exclude from parent folders' if debug?
        else
          add_excludes_from_files(config, config_file)
        end

        merge_with_default(config, config_file).tap do |merged_config|
          warn_on_pending_cops(merged_config.pending_cops) unless possible_new_cops?(merged_config)
        end
      end

      def possible_new_cops?(config)
        disable_pending_cops || enable_pending_cops ||
          config.disabled_new_cops? || config.enabled_new_cops?
      end

      def add_excludes_from_files(config, config_file)
        exclusion_file = find_last_file_upwards(DOTFILE, config_file, project_root)

        return unless exclusion_file
        return if PathUtil.relative_path(exclusion_file) == PathUtil.relative_path(config_file)

        print 'AllCops/Exclude ' if debug?
        config.add_excludes_from_higher_level(load_file(exclusion_file))
      end

      def default_configuration
        @default_configuration ||= begin
          print 'Default ' if debug?
          load_file(DEFAULT_FILE)
        end
      end

      # Returns the path RuboCop inferred as the root of the project. No file
      # searches will go past this directory.
      def project_root
        @project_root ||= find_project_root
      end

      PENDING_BANNER = <<~BANNER
        The following cops were added to RuboCop, but are not configured. Please set Enabled to either `true` or `false` in your `.rubocop.yml` file.

        Please also note that you can opt-in to new cops by default by adding this to your config:
          AllCops:
            NewCops: enable
      BANNER

      def warn_on_pending_cops(pending_cops)
        return if pending_cops.empty?

        warn Rainbow(PENDING_BANNER).yellow

        pending_cops.each { |cop| warn_pending_cop cop }

        warn Rainbow('For more information: https://docs.rubocop.org/rubocop/versioning.html').yellow
      end

      def warn_pending_cop(cop)
        version = cop.metadata['VersionAdded'] || 'N/A'

        warn Rainbow("#{cop.name}: # new in #{version}").yellow
        warn Rainbow('  Enabled: true').yellow
      end

      # Merges the given configuration with the default one.
      def merge_with_default(config, config_file, unset_nil: true)
        resolver.merge_with_default(config, config_file, unset_nil: unset_nil)
      end

      # @api private
      # Used to add features that were required inside a config or from
      # the CLI using `--require`.
      def add_loaded_features(loaded_features)
        @loaded_features.merge(Array(loaded_features))
      end

      private

      def file_path(file)
        File.absolute_path(file.is_a?(RemoteConfig) ? file.file : file)
      end

      def find_project_dotfile(target_dir)
        find_file_upwards(DOTFILE, target_dir, project_root)
      end

      def find_project_root
        pwd = Dir.pwd
        gems_file = find_last_file_upwards('Gemfile', pwd) || find_last_file_upwards('gems.rb', pwd)
        return unless gems_file

        File.dirname(gems_file)
      end

      def find_user_dotfile
        return unless ENV.key?('HOME')

        file = File.join(Dir.home, DOTFILE)
        return file if File.exist?(file)
      end

      def find_user_xdg_config
        xdg_config_home = expand_path(ENV.fetch('XDG_CONFIG_HOME', '~/.config'))
        xdg_config = File.join(xdg_config_home, 'rubocop', XDG_CONFIG)
        return xdg_config if File.exist?(xdg_config)
      end

      def expand_path(path)
        File.expand_path(path)
      rescue ArgumentError
        # Could happen because HOME or ID could not be determined. Fall back on
        # using the path literally in that case.
        path
      end

      def resolver
        @resolver ||= ConfigLoaderResolver.new
      end

      def check_duplication(yaml_code, absolute_path)
        smart_path = PathUtil.smart_path(absolute_path)
        YAMLDuplicationChecker.check(yaml_code, absolute_path) do |key1, key2|
          value = key1.value
          # .start_line is only available since ruby 2.5 / psych 3.0
          message = if key1.respond_to? :start_line
                      line1 = key1.start_line + 1
                      line2 = key2.start_line + 1
                      "#{smart_path}:#{line1}: " \
                        "`#{value}` is concealed by line #{line2}"
                    else
                      "#{smart_path}: `#{value}` is concealed by duplicate"
                    end
          warn Rainbow(message).yellow
        end
      end

      # Read the specified file, or exit with a friendly, concise message on
      # stderr. Care is taken to use the standard OS exit code for a "file not
      # found" error.
      def read_file(absolute_path)
        File.read(absolute_path, encoding: Encoding::UTF_8)
      rescue Errno::ENOENT
        raise ConfigNotFoundError, "Configuration file not found: #{absolute_path}"
      end

      def yaml_safe_load(yaml_code, filename)
        yaml_safe_load!(yaml_code, filename)
      rescue ::StandardError
        if defined?(::SafeYAML)
          raise 'SafeYAML is unmaintained, no longer needed and should be removed'
        end

        raise
      end

      if Gem::Version.new(Psych::VERSION) >= Gem::Version.new('3.1.0')
        def yaml_safe_load!(yaml_code, filename)
          YAML.safe_load(yaml_code,
                         permitted_classes: [Regexp, Symbol],
                         permitted_symbols: [],
                         aliases: true,
                         filename: filename)
        end
      else # Ruby < 2.6
        def yaml_safe_load!(yaml_code, filename)
          YAML.safe_load(yaml_code, [Regexp, Symbol], [], true, filename)
        end
      end
    end

    # Initializing class ivars
    clear_options
  end
end
