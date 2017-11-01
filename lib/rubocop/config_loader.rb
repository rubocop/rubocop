# frozen_string_literal: true

require 'yaml'
require 'pathname'

module RuboCop
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
      include ConfigLoaderResolver

      attr_accessor :debug, :auto_gen_config, :ignore_parent_exclusion
      attr_writer :root_level # The upwards search is stopped at this level.
      attr_writer :default_configuration

      alias debug? debug
      alias auto_gen_config? auto_gen_config
      alias ignore_parent_exclusion? ignore_parent_exclusion

      def clear_options
        @debug = @auto_gen_config = @root_level = nil
      end

      def load_file(file)
        return if file.nil?
        path = File.absolute_path(file.is_a?(RemoteConfig) ? file.file : file)

        hash = load_yaml_configuration(path)

        # Resolve requires first in case they define additional cops
        resolve_requires(path, hash)

        add_missing_namespaces(path, hash)
        target_ruby_version_to_f!(hash)

        resolve_inheritance_from_gems(hash, hash.delete('inherit_gem'))
        resolve_inheritance(path, hash, file)

        hash.delete('inherit_from')

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
        result = base_hash.merge(derived_hash)
        keys_appearing_in_both = base_hash.keys & derived_hash.keys
        keys_appearing_in_both.each do |key|
          next unless base_hash[key].is_a?(Hash)
          result[key] = merge(base_hash[key], derived_hash[key])
        end
        result
      end

      def base_configs(path, inherit_from, file)
        configs = Array(inherit_from).compact.map do |f|
          load_file(inherited_file(path, f, file))
        end

        configs.compact
      end

      def inherited_file(path, inherit_from, file)
        regex = URI::DEFAULT_PARSER.make_regexp(%w[http https])
        if inherit_from =~ /\A#{regex}\z/
          RemoteConfig.new(inherit_from, File.dirname(path))
        elsif file.is_a?(RemoteConfig)
          file.inherit_from_remote(inherit_from, path)
        else
          print 'Inheriting ' if debug?
          File.expand_path(inherit_from, File.dirname(path))
        end
      end

      # Returns the path of .rubocop.yml searching upwards in the
      # directory structure starting at the given directory where the
      # inspected file is. If no .rubocop.yml is found there, the
      # user's home directory is checked. If there's no .rubocop.yml
      # there either, the path to the default file is returned.
      def configuration_file_for(target_dir)
        config_files_in_path(target_dir).first || DEFAULT_FILE
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
        found_files = config_files_in_path(config_file)
        return unless found_files.any? && found_files.last != config_file
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
        default_configuration = self.default_configuration

        disabled_by_default = config.for_all_cops['DisabledByDefault']
        enabled_by_default = config.for_all_cops['EnabledByDefault']

        if disabled_by_default || enabled_by_default
          default_configuration = transform(default_configuration) do |params|
            params.merge('Enabled' => !disabled_by_default)
          end
        end

        if disabled_by_default
          config = handle_disabled_by_default(config, default_configuration)
        end

        Config.new(merge(default_configuration, config), config_file)
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
        File.open(DOTFILE, 'w') do |f|
          f.write "inherit_from:#{file_string}\n\n"
          f.write rubocop_yml_contents if rubocop_yml_contents
        end
        puts "Added inheritance from `#{AUTO_GENERATED_FILE}` in `#{DOTFILE}`."
      end

      private

      def handle_disabled_by_default(config, new_default_configuration)
        department_config = config.to_hash.reject { |cop| cop.include?('/') }
        department_config.each do |dept, dept_params|
          # Rails is always disabled by default and the department's Enabled
          # flag works like the --rails command line option, which is that when
          # AllCops:DisabledByDefault is true, each Rails cop must still be
          # explicitly mentioned in user configuration in order to be enabled.
          next if dept == 'Rails'

          next unless dept_params['Enabled']

          new_default_configuration.each do |cop, params|
            next unless cop.start_with?(dept + '/')

            # Retain original default configuration for cops in the department.
            params['Enabled'] = default_configuration[cop]['Enabled']
          end
        end

        transform(config) do |params|
          { 'Enabled' => true }.merge(params) # Set true if not set.
        end
      end

      # Returns a new hash where the parameters of the given config hash have
      # been replaced by parameters returned by the given block.
      def transform(config)
        Hash[config.map { |cop, params| [cop, yield(params)] }]
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
        warn(format('Configuration file not found: %s', absolute_path))
        exit(Errno::ENOENT::Errno)
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

      def gem_config_path(gem_name, relative_config_path)
        spec = Gem::Specification.find_by_name(gem_name)
        return File.join(spec.gem_dir, relative_config_path)
      rescue Gem::LoadError => e
        raise Gem::LoadError,
              "Unable to find gem #{gem_name}; is the gem installed? #{e}"
      end

      def config_files_in_path(target)
        possible_config_files = dirs_to_search(target).map do |dir|
          File.join(dir, DOTFILE)
        end
        possible_config_files.select { |config_file| File.exist?(config_file) }
      end

      def dirs_to_search(target_dir)
        dirs_to_search = []
        Pathname.new(File.expand_path(target_dir)).ascend do |dir_pathname|
          break if dir_pathname.to_s == @root_level
          dirs_to_search << dir_pathname.to_s
        end
        dirs_to_search << Dir.home if ENV.key? 'HOME'
        dirs_to_search
      end
    end

    # Initializing class ivars
    clear_options
  end
end
