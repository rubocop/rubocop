# encoding: utf-8

require 'delegate'
require 'pathname'

module Rubocop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class Config < DelegateClass(Hash)
    class ValidationError < StandardError; end

    COMMON_PARAMS = %w(Exclude Include Severity)

    attr_reader :loaded_path

    def initialize(hash = {}, loaded_path = nil)
      @hash = hash
      @loaded_path = loaded_path
      super(@hash)
    end

    def for_cop(cop)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      self[cop]
    end

    def cop_enabled?(cop)
      for_cop(cop).nil? || for_cop(cop)['Enabled']
    end

    def warn_unless_valid
      validate
    rescue Config::ValidationError => e
      warn "Warning: #{e.message}".color(:red)
    end

    # TODO: This should be a private method
    def validate
      # Don't validate RuboCop's own files. Avoids inifinite recursion.
      return if @loaded_path.start_with?(ConfigLoader::RUBOCOP_HOME)

      default_config = ConfigLoader.default_configuration

      valid_cop_names, invalid_cop_names = @hash.keys.partition do |key|
        default_config.key?(key)
      end

      invalid_cop_names.each do |name|
        fail ValidationError,
             "unrecognized cop #{name} found in #{loaded_path || self}"
      end

      valid_cop_names.each do |name|
        @hash[name].each_key do |param|
          unless COMMON_PARAMS.include?(param) ||
                 default_config[name].key?(param)
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
      ConfigLoader.relative_path(file, loaded_dir_pathname)
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
