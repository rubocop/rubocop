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
  end
end
