# encoding: utf-8

require 'yaml'
require 'pathname'

module Rubocop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class ConfigLoader
    DOTFILE = '.rubocop.yml'
    RUBOCOP_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(RUBOCOP_HOME, 'config', 'default.yml')
    AUTO_GENERATED_FILE = 'rubocop-todo.yml'

    class << self
      attr_accessor :debug, :auto_gen_config
      attr_writer :root_level # The upwards search is stopped at this level.

      alias_method :debug?, :debug
      alias_method :auto_gen_config?, :auto_gen_config

      def load_file(path)
        path = File.absolute_path(path)
        hash = YAML.load_file(path) || {}
        puts "configuration from #{path}" if debug?

        resolve_inheritance(path, hash)

        hash.delete('inherit_from')
        config = Config.new(hash, path)
        config.warn_unless_valid
        config
      end

      def make_excludes_absolute(config)
        if config['AllCops'] && config['AllCops']['Excludes']
          config['AllCops']['Excludes'].map! do |exclude_elem|
            if exclude_elem.is_a?(String) && !exclude_elem.start_with?('/')
              File.join(File.dirname(config.loaded_path), exclude_elem)
            else
              exclude_elem
            end
          end
        end
      end

      def relative_path(path, base)
        path_name = Pathname.new(File.expand_path(path))
        path_name.relative_path_from(Pathname.new(base)).to_s
      end

      # Return an extended merge of two hashes. That is, a normal hash merge,
      # with the addition that any value that is a hash, and occurs in both
      # arguments (i.e., cop names), will also be merged.
      def merge(base_hash, derived_hash)
        result = base_hash.merge(derived_hash)
        keys_appearing_in_both = base_hash.keys & derived_hash.keys
        keys_appearing_in_both.each do |key|
          if base_hash[key].is_a?(Hash)
            result[key] = base_hash[key].merge(derived_hash[key])
          end
        end
        result
      end

      def base_configs(path, inherit_from)
        Array(inherit_from).map do |f|
          f = File.join(File.dirname(path), f) unless f.start_with?('/')
          if auto_gen_config? && f.include?(AUTO_GENERATED_FILE)
            fail "Remove #{AUTO_GENERATED_FILE} from the current " +
              'configuration before generating it again.'
          end
          print 'Inheriting ' if debug?
          load_file(f)
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

        found_files = config_files_in_path(config_file)
        if found_files.any? && found_files.last != config_file
          print 'AllCops/Excludes ' if debug?
          add_excludes_from_higher_level(config, load_file(found_files.last))
        end
        make_excludes_absolute(config)
        merge_with_default(config, config_file)
      end

      def add_excludes_from_higher_level(config, highest_config)
        if highest_config['AllCops'] && highest_config['AllCops']['Excludes']
          config['AllCops'] ||= {}
          excludes = config['AllCops']['Excludes'] ||= []
          highest_config['AllCops']['Excludes'].each do |path|
            unless path.is_a?(Regexp) || path.start_with?('/')
              path = File.join(File.dirname(highest_config.loaded_path), path)
            end
            excludes << path unless excludes.include?(path)
          end
        end
      end

      def default_configuration
        @default_configuration ||= begin
                                     print 'Default ' if debug?
                                     load_file(DEFAULT_FILE)
                                   end
      end

      def merge_with_default(config, config_file)
        Config.new(merge(default_configuration, config), config_file)
      end

      private

      def resolve_inheritance(path, hash)
        base_configs(path, hash['inherit_from']).reverse_each do |base_config|
          if File.basename(base_config.loaded_path) == DOTFILE
            make_excludes_absolute(base_config)
          end
          base_config.each do |k, v|
            hash[k] = hash.key?(k) ? merge(v, hash[k]) : v if v.is_a?(Hash)
          end
        end
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
        dirs_to_search << Dir.home
      end
    end
  end
end
