# encoding: utf-8

require 'delegate'
require 'pathname'

module RuboCop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class Config < DelegateClass(Hash)
    include PathUtil

    class ValidationError < StandardError; end

    COMMON_PARAMS = %w(Exclude Include Severity AutoCorrect)

    attr_reader :loaded_path

    def initialize(hash = {}, loaded_path = nil)
      @loaded_path = loaded_path
      super(hash)
    end

    def make_excludes_absolute
      keys.each do |key|
        validate_section_presence(key)
        next unless self[key]['Exclude']

        self[key]['Exclude'].map! do |exclude_elem|
          if exclude_elem.is_a?(String) && !exclude_elem.start_with?('/')
            File.expand_path(File.join(base_dir_for_path_parameters,
                                       exclude_elem))
          else
            exclude_elem
          end
        end
      end
    end

    def add_excludes_from_higher_level(highest_config)
      return unless highest_config['AllCops'] &&
                    highest_config['AllCops']['Exclude']

      self['AllCops'] ||= {}
      excludes = self['AllCops']['Exclude'] ||= []
      highest_config['AllCops']['Exclude'].each do |path|
        unless path.is_a?(Regexp) || path.start_with?('/')
          path = File.join(File.dirname(highest_config.loaded_path), path)
        end
        excludes << path unless excludes.include?(path)
      end
    end

    def deprecation_check
      all_cops = self['AllCops']
      return unless all_cops

      %w(Exclude Include).each do |key|
        plural = "#{key}s"
        next unless all_cops[plural]

        all_cops[key] = all_cops[plural] # Stay backwards compatible.
        all_cops.delete(plural)
        yield "AllCops/#{plural} was renamed to AllCops/#{key}"
      end
    end

    def for_cop(cop)
      cop = cop.cop_name if cop.respond_to?(:cop_name)
      @for_cop ||= {}
      @for_cop[cop] ||= self[Cop::Cop.qualified_cop_name(cop, loaded_path)]
    end

    def cop_enabled?(cop)
      for_cop(cop).nil? || for_cop(cop)['Enabled']
    end

    def warn_unless_valid
      validate
    rescue Config::ValidationError => e
      warn "Warning: #{e.message}".color(:red)
    end

    def add_missing_namespaces
      keys.each do |k|
        q = Cop::Cop.qualified_cop_name(k, loaded_path)
        next if q == k

        self[q] = self[k]
        delete(k)
      end
    end

    # TODO: This should be a private method
    def validate
      # Don't validate RuboCop's own files. Avoids infinite recursion.
      base_config_path = File.expand_path(File.join(ConfigLoader::RUBOCOP_HOME,
                                                    'config'))
      return if File.expand_path(loaded_path).start_with?(base_config_path)

      valid_cop_names, invalid_cop_names = keys.partition do |key|
        ConfigLoader.default_configuration.key?(key)
      end

      invalid_cop_names.each do |name|
        fail ValidationError, "unrecognized cop #{name} found in #{loaded_path}"
      end

      validate_parameter_names(valid_cop_names)
    end

    def file_to_include?(file)
      relative_file_path = path_relative_to_config(file)

      # Optimization to quickly decide if the given file is hidden (on the top
      # level) and can not be matched by any pattern.
      is_hidden = relative_file_path.start_with?('.') &&
                  !relative_file_path.start_with?('..')
      return false if is_hidden && !possibly_include_hidden?

      absolute_file_path = File.expand_path(file)

      patterns_to_include.any? do |pattern|
        match_path?(pattern, relative_file_path, loaded_path) ||
          match_path?(pattern, absolute_file_path, loaded_path)
      end
    end

    # Returns true if there's a chance that an Include pattern matches hidden
    # files, false if that's definitely not possible.
    def possibly_include_hidden?
      if @possibly_include_hidden.nil?
        @possibly_include_hidden = patterns_to_include.any? do |s|
          s.is_a?(Regexp) || s.start_with?('.') || s.include?('/.')
        end
      end
      @possibly_include_hidden
    end

    def file_to_exclude?(file)
      file = File.expand_path(file)
      patterns_to_exclude.any? do |pattern|
        match_path?(pattern, file, loaded_path)
      end
    end

    def patterns_to_include
      self['AllCops']['Include']
    end

    def patterns_to_exclude
      self['AllCops']['Exclude']
    end

    def path_relative_to_config(path)
      relative_path(path, base_dir_for_path_parameters)
    end

    # Paths specified in .rubocop.yml files are relative to the directory where
    # that file is. Paths in other config files are relative to the current
    # directory. This is so that paths in config/default.yml, for example, are
    # not relative to RuboCop's config directory since that wouldn't work.
    def base_dir_for_path_parameters
      if File.basename(loaded_path) == ConfigLoader::DOTFILE
        File.expand_path(File.dirname(loaded_path))
      else
        Dir.pwd
      end
    end

    private

    def validate_section_presence(name)
      return unless key?(name) && self[name].nil?
      fail ValidationError, "empty section #{name} found in #{loaded_path}"
    end

    def validate_parameter_names(valid_cop_names)
      valid_cop_names.each do |name|
        validate_section_presence(name)
        self[name].each_key do |param|
          next if COMMON_PARAMS.include?(param) ||
                  ConfigLoader.default_configuration[name].key?(param)

          fail ValidationError,
               "unrecognized parameter #{name}:#{param} found in #{loaded_path}"
        end
      end
    end
  end
end
