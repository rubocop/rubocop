# encoding: utf-8

require 'delegate'
require 'yaml'
require 'pathname'

module Rubocop
  class Configuration < DelegateClass(Hash)
    class ValidationError < StandardError
    end

    DOTFILE = '.rubocop.yml'
    RUBOCOP_HOME_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__),
                                                   '..',
                                                   '..',
                                                   DOTFILE))
    DEFAULT_PATTERNS_TO_INCLUDE = ['**/*.gemspec', '**/Rakefile']
    DEFAULT_PATTERNS_TO_EXCLUDE = []

    attr_reader :loaded_path

    # Returns the configuration instance from .rubocop.yml searching
    # upwards in the directory structure starting at the given
    # directory where the inspected file is. If no .rubocop.yml is
    # found there, the user's home directory is checked.
    def self.configuration_for_path(target_dir)
      return nil unless target_dir

      dirs_to_search(target_dir).each do |dir|
        config_file = File.join(dir, DOTFILE)
        if File.exist?(config_file)
          config = load_file(config_file)
          return config
        end
      end

      nil
    end

    def self.load_file(path)
      hash = YAML.load_file(path)
      new(hash, path)
    end

    def initialize(hash, loaded_path)
      super(hash)
      @hash = hash
      @loaded_path = loaded_path
    end

    def validate!
      valid_cop_names, invalid_cop_names = @hash.keys.partition do |key|
        RUBOCOP_HOME_CONFIG.has_key?(key)
      end

      invalid_cop_names.each do |name|
        fail ValidationError,
             "unrecognized cop #{name} found in #{loaded_path}"
      end

      valid_cop_names.each do |name|
        @hash[name].each_key do |param|
          unless RUBOCOP_HOME_CONFIG[name].has_key?(param)
            fail ValidationError,
                 "unrecognized parameter #{name}:#{param} found " +
                 "in #{loaded_path}"
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
      relative_file_path = relative_path_to_loaded_dir(file)
      patterns_to_exclude.any? do |pattern|
        match_path?(pattern, relative_file_path)
      end
    end

    def patterns_to_include
      if @hash['AllCops'] && @hash['AllCops']['Includes']
        @hash['AllCops']['Includes']
      else
        DEFAULT_PATTERNS_TO_INCLUDE
      end
    end

    def patterns_to_exclude
      if @hash['AllCops'] && @hash['AllCops']['Excludes']
        @hash['AllCops']['Excludes']
      else
        DEFAULT_PATTERNS_TO_EXCLUDE
      end
    end

    private

    def self.dirs_to_search(target_dir)
      dirs_to_search = []
      target_dir_pathname = Pathname.new(File.expand_path(target_dir))
      target_dir_pathname.ascend do |dir_pathname|
        dirs_to_search << dir_pathname.to_s
      end
      dirs_to_search << Dir.home
      dirs_to_search
    end

    def relative_path_to_loaded_dir(file)
      return file unless loaded_path
      file_pathname = Pathname.new(File.expand_path(file))
      file_pathname.relative_path_from(loaded_dir_pathname).to_s
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
