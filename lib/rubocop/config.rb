# encoding: utf-8

require 'delegate'
require 'yaml'
require 'pathname'

module Rubocop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class Config < DelegateClass(Hash)
    class ValidationError < StandardError; end

    DOTFILE = '.rubocop.yml'
    RUBOCOP_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(RUBOCOP_HOME, 'config', 'default.yml')

    attr_reader :loaded_path

    class << self
      def load_file(path)
        path = File.absolute_path(path)
        hash = YAML.load_file(path)

        base_configs(path, hash['inherit_from']).reverse.each do |base_config|
          if File.basename(base_config.loaded_path) == DOTFILE
            make_excludes_absolute(base_config)
          end
          base_config.each do |key, value|
            if value.is_a?(Hash)
              hash[key] = hash.has_key?(key) ? merge(value, hash[key]) : value
            end
          end
        end

        hash.delete('inherit_from')
        config = new(hash, path)
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
        result = {}
        base_hash.each do |key, value|
          result[key] = if derived_hash.has_key?(key)
                          if value.is_a?(Hash)
                            value.merge(derived_hash[key])
                          else
                            derived_hash[key]
                          end
                        else
                          base_hash[key]
                        end
        end
        derived_hash.each do |key, value|
          result[key] = value unless base_hash.has_key?(key)
        end
        result
      end

      def base_configs(path, inherit_from)
        base_files = case inherit_from
                     when nil then []
                     when String then [inherit_from]
                     when Array then inherit_from
                     end
        base_files.map do |f|
          f = File.join(File.dirname(path), f) unless f.start_with?('/')
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
        @default_configuration ||= load_file(DEFAULT_FILE)
      end

      def merge_with_default(config, config_file)
        new(merge(default_configuration, config), config_file)
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

    def initialize(hash = {}, loaded_path = nil)
      @hash = hash
      @loaded_path = loaded_path
      super(@hash)
    end

    def for_cop(cop)
      self[cop]
    end

    def cop_enabled?(cop)
      self[cop].nil? || self[cop]['Enabled']
    end

    def warn_unless_valid
      validate
    rescue Config::ValidationError => e
      puts "Warning: #{e.message}".color(:red)
    end

    # TODO: This should be a private method
    def validate
      # Don't validate RuboCop's own files. Avoids inifinite recursion.
      return if @loaded_path.start_with?(RUBOCOP_HOME)

      default_config = self.class.default_configuration

      valid_cop_names, invalid_cop_names = @hash.keys.partition do |key|
        default_config.has_key?(key)
      end

      invalid_cop_names.each do |name|
        fail ValidationError,
             "unrecognized cop #{name} found in #{loaded_path || self}"
      end

      valid_cop_names.each do |name|
        @hash[name].each_key do |param|
          unless default_config[name].has_key?(param)
            fail ValidationError,
                 "unrecognized parameter #{name}:#{param} found " +
                 "in #{loaded_path || self}"
          end
        end
      end
    end

    def file_to_include?(file)
      relative_file_path = relative_path_to_loaded_dir(file)
      patterns_to_include.any? do |pattern|
        match_path?(pattern, relative_file_path)
      end
    end

    def file_to_exclude?(file)
      file = File.join(Dir.pwd, file) unless file.start_with?('/')
      patterns_to_exclude.any? { |pattern| match_path?(pattern, file) }
    end

    def patterns_to_include
      @hash['AllCops']['Includes']
    end

    def patterns_to_exclude
      @hash['AllCops']['Excludes']
    end

    private

    def relative_path_to_loaded_dir(file)
      return file unless loaded_path
      Config.relative_path(file, loaded_dir_pathname)
    end

    def loaded_dir_pathname
      return nil unless loaded_path
      @loaded_dir ||= begin
        loaded_dir = File.expand_path(File.dirname(loaded_path))
        Pathname.new(loaded_dir)
      end
    end

    def match_path?(pattern, path)
      case pattern
      when String
        File.basename(path) == pattern || File.fnmatch(pattern, path)
      when Regexp
        path =~ pattern
      end
    end
  end
end
