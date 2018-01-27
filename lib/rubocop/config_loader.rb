# frozen_string_literal: true

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
    DOTFILE = '.rubocop.yml'.freeze
    RUBOCOP_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(RUBOCOP_HOME, 'config', 'default.yml')
    AUTO_GENERATED_FILE = '.rubocop_todo.yml'.freeze

    class << self
      include FileFinder

      attr_accessor :debug, :auto_gen_config, :ignore_parent_exclusion
      attr_writer :default_configuration

      alias debug? debug
      alias auto_gen_config? auto_gen_config
      alias ignore_parent_exclusion? ignore_parent_exclusion

      def clear_options
        @debug = @auto_gen_config = nil
        FileFinder.root_level = nil
      end

      def load_file(file)
        return if file.nil?
        path = File.absolute_path(file.is_a?(RemoteConfig) ? file.file : file)

        hash = load_yaml_configuration(path)

        # Resolve requires first in case they define additional cops
        resolver.resolve_requires(path, hash)

        add_missing_namespaces(path, hash)
        target_ruby_version_to_f!(hash)

        resolver.resolve_inheritance_from_gems(hash, hash.delete('inherit_gem'))
        resolver.resolve_inheritance(path, hash, file)

        hash.delete('inherit_from')
        hash.delete('inherit_mode')

        Config.create(hash, path)
      end

      # rubocop:disable Performance/HashEachMethods
      def add_missing_namespaces(path, hash)
        hash.keys.each do |key|
          q = Cop::Cop.qualified_cop_name(key, path)
          next if q == key

          hash[q] = hash.delete(key)
        end
      end
      # rubocop:enable Performance/HashEachMethods

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
        find_file_upwards(DOTFILE, target_dir, use_home: true) || DEFAULT_FILE
      end

      def configuration_from_file(config_file)
        config = load_file(config_file)
        return config if config_file == DEFAULT_FILE

        if ignore_parent_exclusion?
          print 'Ignoring AllCops/Exclude from parent folders' if debug?
        else
          add_excludes_from_files(config, config_file)
        end
        merge_with_default(config, config_file)
      end

      def add_excludes_from_files(config, config_file)
        found_files = find_files_upwards(DOTFILE, config_file, use_home: true)
        return if found_files.empty?
        return if PathUtil.relative_path(found_files.last) ==
                  PathUtil.relative_path(config_file)
        print 'AllCops/Exclude ' if debug?
        config.add_excludes_from_higher_level(load_file(found_files.last))
      end

      def default_configuration
        @default_configuration ||= begin
                                     print 'Default ' if debug?
                                     load_file(DEFAULT_FILE)
                                   end
      end

      # Merges the given configuration with the default one. If
      # AllCops:DisabledByDefault is true, it changes the Enabled params so
      # that only cops from user configuration are enabled.
      # If AllCops::EnabledByDefault is true, it changes the Enabled params
      # so that only cops explicitly disabled in user configuration are
      # disabled.
      def merge_with_default(config, config_file)
        resolver.merge_with_default(config, config_file)
      end

      def target_ruby_version_to_f!(hash)
        version = 'TargetRubyVersion'
        return unless hash['AllCops'] && hash['AllCops'][version]

        hash['AllCops'][version] = hash['AllCops'][version].to_f
      end

      def add_inheritance_from_auto_generated_file
        file_string = " #{AUTO_GENERATED_FILE}"

        if File.exist?(DOTFILE)
          files = Array(load_yaml_configuration(DOTFILE)['inherit_from'])
          return if files.include?(AUTO_GENERATED_FILE)
          files.unshift(AUTO_GENERATED_FILE)
          file_string = "\n  - " + files.join("\n  - ") if files.size > 1
          rubocop_yml_contents = IO.read(DOTFILE, encoding: Encoding::UTF_8)
                                   .sub(/^inherit_from: *[.\w]+/, '')
                                   .sub(/^inherit_from: *(\n *- *[.\w]+)+/, '')
        end
        write_dotfile(file_string, rubocop_yml_contents)
        puts "Added inheritance from `#{AUTO_GENERATED_FILE}` in `#{DOTFILE}`."
      end

      private

      def write_dotfile(file_string, rubocop_yml_contents)
        File.open(DOTFILE, 'w') do |f|
          f.write "inherit_from:#{file_string}\n"
          f.write "\n#{rubocop_yml_contents}" if rubocop_yml_contents
        end
      end

      def resolver
        @resolver ||= ConfigLoaderResolver.new
      end

      def load_yaml_configuration(absolute_path)
        yaml_code = read_file(absolute_path)
        hash = yaml_safe_load(yaml_code, absolute_path) || {}

        puts "configuration from #{absolute_path}" if debug?

        unless hash.is_a?(Hash)
          raise(TypeError, "Malformed configuration in #{absolute_path}")
        end

        hash
      end

      # Read the specified file, or exit with a friendly, concise message on
      # stderr. Care is taken to use the standard OS exit code for a "file not
      # found" error.
      def read_file(absolute_path)
        IO.read(absolute_path, encoding: Encoding::UTF_8)
      rescue Errno::ENOENT
        raise ConfigNotFoundError,
              "Configuration file not found: #{absolute_path}"
      end

      def yaml_safe_load(yaml_code, filename)
        if YAML.respond_to?(:safe_load) # Ruby 2.1+
          if defined?(SafeYAML) && SafeYAML.respond_to?(:load)
            SafeYAML.load(yaml_code, filename,
                          whitelisted_tags: %w[!ruby/regexp])
          else
            YAML.safe_load(yaml_code, [Regexp, Symbol], [], false, filename)
          end
        else
          YAML.load(yaml_code, filename) # rubocop:disable Security/YAMLLoad
        end
      end
    end

    # Initializing class ivars
    clear_options
  end
end
