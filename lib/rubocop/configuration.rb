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
      include_files.any? do |include_match|
        rel_file = relative_to_config_path(file)
        match_file(include_match, rel_file)
      end
    end

    def file_to_exclude?(file)
      exclude_files.any? do |include_match|
        rel_file = relative_to_config_path(file)
        match_file(include_match, rel_file)
      end
    end

    def include_files
      if @hash['AllCops'] && @hash['AllCops']['Includes']
        @hash['AllCops']['Includes']
      else
        ['**/*.gemspec', '**/Rakefile']
      end
    end

    def exclude_files
      if @hash['AllCops'] && @hash['AllCops']['Excludes']
        @hash['AllCops']['Excludes']
      else
        []
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

    def relative_to_config_path(file)
      return file unless loaded_path
      absolute_file = File.expand_path(file)
      config_dir =  File.expand_path(File.dirname(loaded_path))
      config_dir_path = Pathname.new(config_dir)
      file_path = Pathname.new(absolute_file)
      file_path.relative_path_from(config_dir_path).to_s
    end

    def match_file(match, file)
      if match.is_a? String
        File.basename(file) == match ||
        File.fnmatch(match, file)
      elsif match.is_a? Regexp
        file =~ match
      end
    end
  end
end
