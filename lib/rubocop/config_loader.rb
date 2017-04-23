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

      attr_accessor :debug, :auto_gen_config
      attr_writer :root_level # The upwards search is stopped at this level.
      attr_writer :default_configuration

      alias debug? debug
      alias auto_gen_config? auto_gen_config

      def clear_options
        @debug = @auto_gen_config = @root_level = nil
      end

      def load_file(path)
        path = File.absolute_path(path)
        hash = load_yaml_configuration(path)

        # Resolve requires first in case they define additional cops
        resolve_requires(path, hash)

        add_missing_namespaces(path, hash)
        target_ruby_version_to_f!(hash)

        resolve_inheritance_from_gems(hash, hash.delete('inherit_gem'))
        resolve_inheritance(path, hash)

        hash.delete('inherit_from')

        create_config(hash, path)
      end

      def create_config(hash, path)
        config = Config.new(hash, path)

        config.deprecation_check do |deprecation_message|
          warn("#{path} - #{deprecation_message}")
        end

        config.validate
        config.make_excludes_absolute
        config
      end

      def add_missing_namespaces(path, hash)
        hash.keys.each do |k|
          q = Cop::Cop.qualified_cop_name(k, path)
          next if q == k

          hash[q] = hash.delete(k)
        end
      end

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

      def base_configs(path, inherit_from)
        configs = Array(inherit_from).compact.map do |f|
          if f =~ /\A#{URI::Parser.new.make_regexp(%w[http https])}\z/
            f = RemoteConfig.new(f, File.dirname(path)).file
          else
            f = File.expand_path(f, File.dirname(path))

            if auto_gen_config?
              next if f.include?(AUTO_GENERATED_FILE)
            end

            print 'Inheriting ' if debug?
          end
          load_file(f)
        end

        configs.compact
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

        found_files = config_files_in_path(config_file)
        if found_files.any? && found_files.last != config_file
          print 'AllCops/Exclude ' if debug?
          config.add_excludes_from_higher_level(load_file(found_files.last))
        end
        merge_with_default(config, config_file)
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

      private

      def handle_disabled_by_default(config, new_default_configuration)
        department_config = config.to_hash.reject { |cop| cop.include?('/') }
        department_config.each do |dept, dept_params|
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
        yaml_code = IO.read(absolute_path, encoding: Encoding::UTF_8)
        hash = yaml_safe_load(yaml_code, absolute_path) || {}

        puts "configuration from #{absolute_path}" if debug?

        unless hash.is_a?(Hash)
          raise(TypeError, "Malformed configuration in #{absolute_path}")
        end

        hash
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
