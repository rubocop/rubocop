# frozen_string_literal: true

require 'pathname'

# rubocop:disable Metrics/ClassLength

module RuboCop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class Config
    include PathUtil

    COMMON_PARAMS = %w(Exclude Include Severity
                       AutoCorrect StyleGuide Details).freeze
    # 2.1 is the oldest officially supported Ruby version.
    DEFAULT_RUBY_VERSION = 2.1
    KNOWN_RUBIES = [1.9, 2.0, 2.1, 2.2, 2.3, 2.4].freeze
    OBSOLETE_COPS = {
      'Style/TrailingComma' =>
        'The `Style/TrailingComma` cop no longer exists. Please use ' \
        '`Style/TrailingCommaInLiteral` and/or ' \
        '`Style/TrailingCommaInArguments` instead.',
      'Rails/DefaultScope' =>
        'The `Rails/DefaultScope` cop no longer exists.',
      'Style/SingleSpaceBeforeFirstArg' =>
        'The `Style/SingleSpaceBeforeFirstArg` cop has been renamed to ' \
        '`Style/SpaceBeforeFirstArg. ',
      'Lint/SpaceBeforeFirstArg' =>
        'The `Lint/SpaceBeforeFirstArg` cop has been removed, since it was a ' \
        'duplicate of `Style/SpaceBeforeFirstArg`. Please use ' \
        '`Style/SpaceBeforeFirstArg` instead.',
      'Style/SpaceAfterControlKeyword' =>
        'The `Style/SpaceAfterControlKeyword` cop has been removed. Please ' \
        'use `Style/SpaceAroundKeyword` instead.',
      'Style/SpaceBeforeModifierKeyword' =>
        'The `Style/SpaceBeforeModifierKeyword` cop has been removed. Please ' \
        'use `Style/SpaceAroundKeyword` instead.'
    }.freeze

    attr_reader :loaded_path

    def initialize(hash = {}, loaded_path = nil)
      @loaded_path = loaded_path
      @for_cop = Hash.new do |h, cop|
        h[cop] = self[Cop::Cop.qualified_cop_name(cop, loaded_path)] || {}
      end
      @hash = hash
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @hash[key] = value
    end

    def delete(key)
      @hash.delete(key)
    end

    def each(&block)
      @hash.each(&block)
    end

    def key?(key)
      @hash.key?(key)
    end

    def keys
      @hash.keys
    end

    def map(&block)
      @hash.map(&block)
    end

    def merge(other_hash)
      @hash.merge(other_hash)
    end

    def to_h
      @hash
    end

    def to_hash
      @hash
    end

    def to_s
      @to_s ||= @hash.to_s
    end

    def make_excludes_absolute
      each do |key, _|
        validate_section_presence(key)
        next unless self[key]['Exclude']

        self[key]['Exclude'].map! do |exclude_elem|
          if exclude_elem.is_a?(String) && !absolute?(exclude_elem)
            File.expand_path(File.join(base_dir_for_path_parameters,
                                       exclude_elem))
          else
            exclude_elem
          end
        end
      end
    end

    def add_excludes_from_higher_level(highest_config)
      return unless highest_config.for_all_cops['Exclude']

      excludes = for_all_cops['Exclude'] ||= []
      highest_config.for_all_cops['Exclude'].each do |path|
        unless path.is_a?(Regexp) || absolute?(path)
          path = File.join(File.dirname(highest_config.loaded_path), path)
        end
        excludes << path unless excludes.include?(path)
      end
    end

    def deprecation_check
      %w(Exclude Include).each do |key|
        plural = "#{key}s"
        next unless for_all_cops[plural]

        for_all_cops[key] = for_all_cops[plural] # Stay backwards compatible.
        for_all_cops.delete(plural)
        yield "AllCops/#{plural} was renamed to AllCops/#{key}"
      end
    end

    def for_cop(cop)
      @for_cop[cop.respond_to?(:cop_name) ? cop.cop_name : cop]
    end

    def for_all_cops
      self['AllCops'] || {}
    end

    def cop_enabled?(cop)
      department = cop.cop_type.to_s.capitalize!

      if (dept_config = self[department])
        return false if dept_config['Enabled'] == false
      end

      for_cop(cop).empty? || for_cop(cop)['Enabled']
    end

    def validate
      # Don't validate RuboCop's own files. Avoids infinite recursion.
      base_config_path = File.expand_path(File.join(ConfigLoader::RUBOCOP_HOME,
                                                    'config'))
      return if File.expand_path(loaded_path).start_with?(base_config_path)

      valid_cop_names, invalid_cop_names = keys.partition do |key|
        ConfigLoader.default_configuration.key?(key)
      end

      reject_obsolete_cops
      warn_about_unrecognized_cops(invalid_cop_names)
      reject_obsolete_parameters
      check_target_ruby
      validate_parameter_names(valid_cop_names)
      validate_enforced_styles(valid_cop_names)
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
        match_path?(pattern, relative_file_path) ||
          match_path?(pattern, absolute_file_path)
      end
    end

    # Returns true if there's a chance that an Include pattern matches hidden
    # files, false if that's definitely not possible.
    def possibly_include_hidden?
      return @possibly_include_hidden if defined?(@possibly_include_hidden)

      @possibly_include_hidden = patterns_to_include.any? do |s|
        s.is_a?(Regexp) || s.start_with?('.') || s.include?('/.')
      end
    end

    def file_to_exclude?(file)
      file = File.expand_path(file)
      patterns_to_exclude.any? do |pattern|
        match_path?(pattern, file)
      end
    end

    def patterns_to_include
      for_all_cops['Include']
    end

    def patterns_to_exclude
      for_all_cops['Exclude']
    end

    def path_relative_to_config(path)
      relative_path(path, base_dir_for_path_parameters)
    end

    # Paths specified in .rubocop.yml and .rubocop_todo.yml files are relative
    # to the directory where that file is. Paths in other config files are
    # relative to the current directory. This is so that paths in
    # config/default.yml, for example, are not relative to RuboCop's config
    # directory since that wouldn't work.
    def base_dir_for_path_parameters
      config_files = [ConfigLoader::DOTFILE, ConfigLoader::AUTO_GENERATED_FILE]
      @base_dir_for_path_parameters ||=
        if config_files.include?(File.basename(loaded_path)) &&
           loaded_path != File.join(Dir.home, ConfigLoader::DOTFILE)
          File.expand_path(File.dirname(loaded_path))
        else
          Dir.pwd
        end
    end

    def target_ruby_version
      @target_ruby_version ||=
        if for_all_cops['TargetRubyVersion']
          @target_ruby_version_source = :rubocop_yml

          for_all_cops['TargetRubyVersion']
        elsif File.file?('.ruby-version') &&
              /\A(ruby-)?(?<version>\d+\.\d+)/ =~ File.read('.ruby-version')

          @target_ruby_version_source = :dot_ruby_version

          version.to_f
        else
          DEFAULT_RUBY_VERSION
        end
    end

    private

    def warn_about_unrecognized_cops(invalid_cop_names)
      invalid_cop_names.each do |name|
        if name == 'Syntax'
          raise ValidationError,
                "configuration for Syntax cop found in #{loaded_path}\n" \
                'This cop cannot be configured.'
        end

        # There could be a custom cop with this name. If so, don't warn
        next if Cop::Cop.all.any? { |c| c.match?([name]) }

        warn Rainbow("Warning: unrecognized cop #{name} found in " \
                     "#{loaded_path}").yellow
      end
    end

    def validate_section_presence(name)
      return unless key?(name) && self[name].nil?
      raise ValidationError, "empty section #{name} found in #{loaded_path}"
    end

    def validate_parameter_names(valid_cop_names)
      valid_cop_names.each do |name|
        validate_section_presence(name)
        self[name].each_key do |param|
          next if COMMON_PARAMS.include?(param) ||
                  ConfigLoader.default_configuration[name].key?(param)

          warn Rainbow("Warning: unrecognized parameter #{name}:#{param} " \
                       "found in #{loaded_path}").yellow
        end
      end
    end

    def validate_enforced_styles(valid_cop_names)
      valid_cop_names.each do |name|
        next unless (style = self[name]['EnforcedStyle'])
        valid = ConfigLoader.default_configuration[name]['SupportedStyles']
        next if valid.include?(style)

        msg = "invalid EnforcedStyle '#{style}' for #{name} found in " \
              "#{loaded_path}\n" \
              "Valid choices are: #{valid.join(', ')}"
        raise ValidationError, msg
      end
    end

    def reject_obsolete_parameters
      check_obsolete_parameter('Style/SpaceAroundOperators',
                               'MultiSpaceAllowedForOperators',
                               'If your intention was to allow extra spaces ' \
                               'for alignment, please use AllowForAlignment: ' \
                               'true instead.')
      check_obsolete_parameter('AllCops', 'RunRailsCops',
                               "Use the following configuration instead:\n" \
                               "Rails:\n  Enabled: true")
    end

    def check_obsolete_parameter(cop, parameter, alternative = nil)
      return unless self[cop] && self[cop].key?(parameter)

      raise ValidationError, "obsolete parameter #{parameter} (for #{cop}) " \
                            "found in #{loaded_path}" \
                            "#{"\n" if alternative}#{alternative}"
    end

    def reject_obsolete_cops
      OBSOLETE_COPS.each do |cop_name, message|
        next unless key?(cop_name) || key?(cop_name.split('/').last)
        message += "\n(obsolete configuration found in #{loaded_path}, please" \
                   ' update it)'
        raise ValidationError, message
      end
    end

    def check_target_ruby
      return if KNOWN_RUBIES.include?(target_ruby_version)

      msg = "Unknown Ruby version #{target_ruby_version.inspect} found "

      msg +=
        case @target_ruby_version_source
        when :dot_ruby_version
          'in `.ruby-version`.'
        when :rubocop_yml
          "in `TargetRubyVersion` parameter (in #{loaded_path})." \
        end

      msg += "\nKnown versions: #{KNOWN_RUBIES.join(', ')}"

      raise ValidationError, msg
    end
  end
end
