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
      attr_accessor :debug
      alias_method :debug?, :debug

      def load_file(path)
        path = File.absolute_path(path)
        hash = YAML.load_file(path)
        puts "configuration from #{path}" if debug?
        contains_auto_generated_config = false

        base_configs(path, hash['inherit_from']).reverse_each do |base_config|
          if File.basename(base_config.loaded_path) == DOTFILE
            make_excludes_absolute(base_config)
          end
          base_config.each do |key, value|
            if value.is_a?(Hash)
              hash[key] = hash.key?(key) ? merge(value, hash[key]) : value
            end
          end
          if base_config.loaded_path.include?(AUTO_GENERATED_FILE)
            contains_auto_generated_config = true
          end
        end

        hash.delete('inherit_from')
        config = Config.new(hash, path)
        config.warn_unless_valid
        config.contains_auto_generated_config = contains_auto_generated_config
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
          config['AllCops']['Excludes'] ||= []
          highest_config['AllCops']['Excludes'].each do |path|
            unless path.is_a?(Regexp) || path.start_with?('/')
              path = File.join(File.dirname(highest_config.loaded_path), path)
            end
            config['AllCops']['Excludes'] << path
          end
          config['AllCops']['Excludes'].uniq!
        end
      end

      def default_configuration
        @default_configuration ||= begin
                                     print 'Default ' if debug?
                                     load_file(DEFAULT_FILE)
                                   end
      end

      def merge_with_default(config, config_file)
        result = Config.new(merge(default_configuration, config), config_file)
        result.contains_auto_generated_config =
          config.contains_auto_generated_config
        result
      end

      private

      def config_files_in_path(target)
        possible_config_files = dirs_to_search(target).map do |dir|
          File.join(dir, DOTFILE)
        end
        possible_config_files.select { |config_file| File.exist?(config_file) }
      end

      def dirs_to_search(target_dir)
        dirs_to_search = []
        target_dir_pathname = Pathname.new(File.expand_path(target_dir))
        target_dir_pathname.ascend do |dir_pathname|
          dirs_to_search << dir_pathname.to_s
        end
        dirs_to_search << Dir.home
        dirs_to_search
      end
    end
  end
end
