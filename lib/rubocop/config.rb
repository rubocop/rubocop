# frozen_string_literal: true

require 'pathname'

module RuboCop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.

  # rubocop:disable Metrics/ClassLength
  class Config
    include PathUtil
    include FileFinder

    COMMON_PARAMS = %w[Exclude Include Severity
                       AutoCorrect StyleGuide Details].freeze
    # 2.2 is the oldest officially supported Ruby version.
    DEFAULT_RUBY_VERSION = 2.2
    KNOWN_RUBIES = [2.2, 2.3, 2.4, 2.5, 2.6].freeze
    OBSOLETE_RUBIES = { 1.9 => '0.50', 2.0 => '0.50', 2.1 => '0.58' }.freeze
    RUBY_VERSION_FILENAME = '.ruby-version'.freeze
    DEFAULT_RAILS_VERSION = 5.0
    OBSOLETE_COPS = {
      'Style/TrailingComma' =>
        'The `Style/TrailingComma` cop no longer exists. Please use ' \
        '`Style/TrailingCommaInArguments`, ' \
        '`Style/TrailingCommaInArrayLiteral`, and/or ' \
        '`Style/TrailingCommaInHashLiteral` instead.',
      'Style/TrailingCommaInLiteral' =>
        'The `Style/TrailingCommaInLiteral` cop no longer exists. Please use ' \
        '`Style/TrailingCommaInArrayLiteral` and/or ' \
        '`Style/TrailingCommaInHashLiteral` instead.',
      'Rails/DefaultScope' =>
        'The `Rails/DefaultScope` cop no longer exists.',
      'Lint/InvalidCharacterLiteral' =>
        'The `Lint/InvalidCharacterLiteral` cop has been removed since it ' \
        'was never being actually triggered.',
      'Style/SingleSpaceBeforeFirstArg' =>
        'The `Style/SingleSpaceBeforeFirstArg` cop has been renamed to ' \
        '`Layout/SpaceBeforeFirstArg`.',
      'Lint/RescueWithoutErrorClass' =>
        'The `Lint/RescueWithoutErrorClass` cop has been replaced by ' \
        '`Style/RescueStandardError`.',
      'Lint/SpaceBeforeFirstArg' =>
        'The `Lint/SpaceBeforeFirstArg` cop has been removed, since it was a ' \
        'duplicate of `Layout/SpaceBeforeFirstArg`. Please use ' \
        '`Layout/SpaceBeforeFirstArg` instead.',
      'Layout/SpaceAfterControlKeyword' =>
        'The `Layout/SpaceAfterControlKeyword` cop has been removed. Please ' \
        'use `Layout/SpaceAroundKeyword` instead.',
      'Layout/SpaceBeforeModifierKeyword' =>
        'The `Layout/SpaceBeforeModifierKeyword` cop has been removed. ' \
        'Please use `Layout/SpaceAroundKeyword` instead.',
      'Style/SpaceAfterControlKeyword' =>
        'The `Style/SpaceAfterControlKeyword` cop has been removed. Please ' \
        'use `Layout/SpaceAroundKeyword` instead.',
      'Style/SpaceBeforeModifierKeyword' =>
        'The `Style/SpaceBeforeModifierKeyword` cop has been removed. Please ' \
        'use `Layout/SpaceAroundKeyword` instead.',
      'Style/MethodCallParentheses' =>
        'The `Style/MethodCallParentheses` cop has been renamed to ' \
          '`Style/MethodCallWithoutArgsParentheses`.',
      'Lint/Eval' =>
        'The `Lint/Eval` cop has been renamed to `Security/Eval`.',
      'Style/DeprecatedHashMethods' =>
        'The `Style/DeprecatedHashMethods` cop has been renamed to ' \
          '`Style/PreferredHashMethods`.',
      'Style/AccessorMethodName' =>
        'The `Style/AccessorMethodName` cop has been moved to ' \
          '`Naming/AccessorMethodName`.',
      'Style/AsciiIdentifiers' =>
        'The `Style/AsciiIdentifiers` cop has been moved to ' \
          '`Naming/AccessorMethodName`.',
      'Style/OpMethod' =>
        'The `Style/OpMethod` cop has been renamed and moved to ' \
          '`Naming/BinaryOperatorParameterName`.',
      'Style/ClassAndModuleCamelCase' =>
        'The `Style/ClassAndModuleCamelCase` cop has been renamed to ' \
          '`Naming/ClassAndModuleCamelCase`.',
      'Style/ConstantName' =>
        'The `Style/ConstantName` cop has been renamed to ' \
          '`Naming/ConstantName`.',
      'Style/FileName' =>
        'The `Style/FileName` cop has been renamed to `Naming/FileName`.',
      'Style/MethodName' =>
        'The `Style/MethodName` cop has been renamed to ' \
          '`Naming/MethodName`.',
      'Style/PredicateName' =>
        'The `Style/PredicateName` cop has been renamed to ' \
          '`Naming/PredicateName`.',
      'Style/VariableName' =>
        'The `Style/VariableName` cop has been renamed to ' \
          '`Naming/VariableName`.',
      'Style/VariableNumber' =>
        'The `Style/VariableNumber` cop has been renamed to ' \
          '`Naming/VariableNumber`.',
      'Lint/BlockAlignment' =>
        'The `Lint/BlockAlignment` cop has been renamed to ' \
          '`Layout/BlockAlignment`.',
      'Lint/EndAlignment' =>
        'The `Lint/EndAlignment` cop has been renamed to ' \
          '`Layout/EndAlignment`.',
      'Lint/DefEndAlignment' =>
        'The `Lint/DefEndAlignment` cop has been renamed to ' \
          '`Layout/DefEndAlignment`.',
      'Performance/HashEachMethods' =>
        'The `Performance/HashEachMethods` cop has been removed ' \
          'since it no longer provides performance benefits in ' \
          'modern rubies.',
      'Style/MethodMissing' =>
        'The `Style/MethodMissing` cop has been split into ' \
          '`Style/MethodMissingSuper` and `Style/MissingRespondToMissing`.'
    }.freeze

    OBSOLETE_PARAMETERS = [
      {
        cop: 'Layout/SpaceAroundOperators',
        parameter: 'MultiSpaceAllowedForOperators',
        alternative: 'If your intention was to allow extra spaces ' \
                     'for alignment, please use AllowForAlignment: ' \
                     'true instead.'
      },
      {
        cop: 'Style/Encoding',
        parameter: 'EnforcedStyle',
        alternative: 'Style/Encoding no longer supports styles. ' \
                     'The "never" behavior is always assumed.'
      },
      {
        cop: 'Style/Encoding',
        parameter: 'SupportedStyles',
        alternative: 'Style/Encoding no longer supports styles. ' \
                     'The "never" behavior is always assumed.'
      },
      {
        cop: 'Style/Encoding',
        parameter: 'AutoCorrectEncodingComment',
        alternative: 'Style/Encoding no longer supports styles. ' \
                     'The "never" behavior is always assumed.'
      },
      {
        cop: 'Style/IfUnlessModifier',
        parameter: 'MaxLineLength',
        alternative:
          '`Style/IfUnlessModifier: MaxLineLength` has been removed. Use ' \
          '`Metrics/LineLength: Max` instead'
      },
      {
        cop: 'Style/SpaceAroundOperators',
        parameter: 'MultiSpaceAllowedForOperators',
        alternative: 'If your intention was to allow extra spaces ' \
                     'for alignment, please use AllowForAlignment: ' \
                     'true instead.'
      },
      {
        cop: 'Style/WhileUntilModifier',
        parameter: 'MaxLineLength',
        alternative:
          '`Style/WhileUntilModifier: MaxLineLength` has been removed. Use ' \
          '`Metrics/LineLength: Max` instead'
      },
      {
        cop: 'AllCops',
        parameter: 'RunRailsCops',
        alternative: "Use the following configuration instead:\n" \
                     "Rails:\n  Enabled: true"
      },
      {
        cop: 'Layout/CaseIndentation',
        parameter: 'IndentWhenRelativeTo',
        alternative: '`IndentWhenRelativeTo` has been renamed to ' \
                     '`EnforcedStyle`'
      },
      {
        cop: 'Lint/BlockAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Layout/BlockAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Lint/EndAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Layout/EndAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Lint/DefEndAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Layout/DefEndAlignment',
        parameter: 'AlignWith',
        alternative: '`AlignWith` has been renamed to ' \
                     '`EnforcedStyleAlignWith`'
      },
      {
        cop: 'Rails/UniqBeforePluck',
        parameter: 'EnforcedMode',
        alternative: '`EnforcedMode` has been renamed to ' \
                     '`EnforcedStyle`'
      }
    ].freeze

    attr_reader :loaded_path

    def initialize(hash = {}, loaded_path = nil)
      @loaded_path = loaded_path
      @for_cop = Hash.new do |h, cop|
        qualified_cop_name = Cop::Cop.qualified_cop_name(cop, loaded_path)
        cop_options = self[qualified_cop_name] || {}
        cop_options['Enabled'] = enable_cop?(qualified_cop_name, cop_options)
        h[cop] = cop_options
      end
      @hash = hash
    end

    def self.create(hash, path)
      new(hash, path).check
    end

    def check
      deprecation_check do |deprecation_message|
        warn("#{loaded_path} - #{deprecation_message}")
      end
      validate
      make_excludes_absolute
      self
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

    def each_key(&block)
      @hash.each_key(&block)
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

    def signature
      @signature ||= Digest::MD5.hexdigest(to_s)
    end

    def make_excludes_absolute
      each_key do |key|
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
      %w[Exclude Include].each do |key|
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
      @for_all_cops ||= self['AllCops'] || {}
    end

    def validate
      # Don't validate RuboCop's own files. Avoids infinite recursion.
      base_config_path = File.expand_path(File.join(ConfigLoader::RUBOCOP_HOME,
                                                    'config'))
      return if File.expand_path(loaded_path).start_with?(base_config_path)

      valid_cop_names, invalid_cop_names = keys.partition do |key|
        ConfigLoader.default_configuration.key?(key)
      end

      reject_obsolete_cops_and_parameters
      warn_about_unrecognized_cops(invalid_cop_names)
      check_target_ruby
      validate_parameter_names(valid_cop_names)
      validate_enforced_styles(valid_cop_names)
      validate_syntax_cop
      reject_mutually_exclusive_defaults
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
        if block_given?
          yield pattern, relative_file_path, absolute_file_path
        else
          match_path?(pattern, relative_file_path) ||
            match_path?(pattern, absolute_file_path)
        end
      end
    end

    def allowed_camel_case_file?(file)
      # Gemspecs are allowed to have dashes because that fits with bundler best
      # practices in the case when the gem is nested under a namespace (e.g.,
      # `bundler-console` conveys `Bundler::Console`).
      return true if File.extname(file) == '.gemspec'

      file_to_include?(file) do |pattern, relative_path, absolute_path|
        pattern.to_s =~ /[A-Z]/ &&
          (match_path?(pattern, relative_path) ||
           match_path?(pattern, absolute_path))
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
      for_all_cops['Include'] || []
    end

    def patterns_to_exclude
      for_all_cops['Exclude'] || []
    end

    def path_relative_to_config(path)
      relative_path(path, base_dir_for_path_parameters)
    end

    # Paths specified in configuration files starting with .rubocop are
    # relative to the directory where that file is. Paths in other config files
    # are relative to the current directory. This is so that paths in
    # config/default.yml, for example, are not relative to RuboCop's config
    # directory since that wouldn't work.
    def base_dir_for_path_parameters
      @base_dir_for_path_parameters ||=
        if File.basename(loaded_path).start_with?('.rubocop') &&
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
        elsif target_ruby_version_from_version_file
          @target_ruby_version_source = :ruby_version_file

          target_ruby_version_from_version_file
        elsif target_ruby_version_from_bundler_lock_file
          @target_ruby_version_source = :bundler_lock_file

          target_ruby_version_from_bundler_lock_file
        else
          DEFAULT_RUBY_VERSION
        end
    end

    def target_rails_version
      @target_rails_version ||=
        if for_all_cops['TargetRailsVersion']
          for_all_cops['TargetRailsVersion'].to_f
        elsif target_rails_version_from_bundler_lock_file
          target_rails_version_from_bundler_lock_file
        else
          DEFAULT_RAILS_VERSION
        end
    end

    private

    def warn_about_unrecognized_cops(invalid_cop_names)
      invalid_cop_names.each do |name|
        # There could be a custom cop with this name. If so, don't warn
        next if Cop::Cop.registry.contains_cop_matching?([name])

        # Special case for inherit_mode, which is a directive that we keep in
        # the configuration (even though it's not a cop), because it's easier
        # to do so than to pass the value around to various methods.
        next if name == 'inherit_mode'

        warn Rainbow("Warning: unrecognized cop #{name} found in " \
                     "#{smart_loaded_path}").yellow
      end
    end

    def validate_syntax_cop
      syntax_config = self['Lint/Syntax']
      default_config = ConfigLoader.default_configuration['Lint/Syntax']

      return unless syntax_config &&
                    default_config.merge(syntax_config) != default_config

      raise ValidationError,
            "configuration for Syntax cop found in #{smart_loaded_path}\n" \
            'It\'s not possible to disable this cop.'
    end

    def validate_section_presence(name)
      return unless key?(name) && self[name].nil?

      raise ValidationError,
            "empty section #{name} found in #{smart_loaded_path}"
    end

    def validate_parameter_names(valid_cop_names)
      valid_cop_names.each do |name|
        validate_section_presence(name)
        self[name].each_key do |param|
          next if COMMON_PARAMS.include?(param) ||
                  ConfigLoader.default_configuration[name].key?(param)

          warn Rainbow("Warning: unrecognized parameter #{name}:#{param} " \
                       "found in #{smart_loaded_path}").yellow
        end
      end
    end

    def validate_enforced_styles(valid_cop_names)
      valid_cop_names.each do |name|
        styles = self[name].select { |key, _| key.start_with?('Enforced') }

        styles.each do |style_name, style|
          supported_key = RuboCop::Cop::Util.to_supported_styles(style_name)
          valid = ConfigLoader.default_configuration[name][supported_key]
          next unless valid
          next if valid.include?(style)

          msg = "invalid #{style_name} '#{style}' for #{name} found in " \
            "#{smart_loaded_path}\n" \
            "Valid choices are: #{valid.join(', ')}"
          raise ValidationError, msg
        end
      end
    end

    def reject_obsolete_cops_and_parameters
      messages = [
        obsolete_cops,
        obsolete_parameters
      ].flatten.compact
      return if messages.empty?

      raise ValidationError, messages.join("\n")
    end

    def obsolete_parameters
      OBSOLETE_PARAMETERS.map do |params|
        obsolete_parameter_message(params[:cop], params[:parameter],
                                   params[:alternative])
      end
    end

    def obsolete_parameter_message(cop, parameter, alternative)
      return unless self[cop] && self[cop].key?(parameter)

      "obsolete parameter #{parameter} (for #{cop}) " \
        "found in #{smart_loaded_path}" \
        "\n#{alternative}"
    end

    def obsolete_cops
      OBSOLETE_COPS.map do |cop_name, message|
        next unless key?(cop_name) || key?(Cop::Badge.parse(cop_name).cop_name)

        message + "\n(obsolete configuration found in #{smart_loaded_path}," \
                   ' please update it)'
      end
    end

    def check_target_ruby
      return if KNOWN_RUBIES.include?(target_ruby_version)

      msg = if OBSOLETE_RUBIES.include?(target_ruby_version)
              "Unsupported Ruby version #{target_ruby_version} found in " \
              "#{target_ruby_source}. #{target_ruby_version}-compatible " \
              'analysis was dropped after version ' \
              "#{OBSOLETE_RUBIES[target_ruby_version]}."
            else
              "Unknown Ruby version #{target_ruby_version.inspect} found in " \
              "#{target_ruby_source}."
            end

      msg += "\nSupported versions: #{KNOWN_RUBIES.join(', ')}"

      raise ValidationError, msg
    end

    def target_ruby_source
      case @target_ruby_version_source
      when :ruby_version_file
        "`#{RUBY_VERSION_FILENAME}`"
      when :bundler_lock_file
        "`#{bundler_lock_file_path}`"
      when :rubocop_yml
        "`TargetRubyVersion` parameter (in #{smart_loaded_path})"
      end
    end

    def ruby_version_file
      @ruby_version_file ||=
        find_file_upwards(RUBY_VERSION_FILENAME, base_dir_for_path_parameters)
    end

    def target_ruby_version_from_version_file
      file = ruby_version_file
      return unless file && File.file?(file)

      @target_ruby_version_from_version_file ||=
        File.read(file).match(/\A(ruby-)?(?<version>\d+\.\d+)/) do |md|
          md[:version].to_f
        end
    end

    def target_ruby_version_from_bundler_lock_file
      @target_ruby_version_from_bundler_lock_file ||=
        read_ruby_version_from_bundler_lock_file
    end

    def read_ruby_version_from_bundler_lock_file
      lock_file_path = bundler_lock_file_path
      return nil unless lock_file_path

      in_ruby_section = false
      File.foreach(lock_file_path) do |line|
        # If ruby is in Gemfile.lock or gems.lock, there should be two lines
        # towards the bottom of the file that look like:
        #     RUBY VERSION
        #       ruby W.X.YpZ
        # We ultimately want to match the "ruby W.X.Y.pZ" line, but there's
        # extra logic to make sure we only start looking once we've seen the
        # "RUBY VERSION" line.
        in_ruby_section ||= line.match(/^\s*RUBY\s*VERSION\s*$/)
        next unless in_ruby_section

        # We currently only allow this feature to work with MRI ruby. If jruby
        # (or something else) is used by the project, it's lock file will have a
        # line that looks like:
        #     RUBY VERSION
        #       ruby W.X.YpZ (jruby x.x.x.x)
        # The regex won't match in this situation.
        result = line.match(/^\s*ruby\s+(\d+\.\d+)[p.\d]*\s*$/)
        return result.captures.first.to_f if result
      end
    end

    def target_rails_version_from_bundler_lock_file
      @target_rails_version_from_bundler_lock_file ||=
        read_rails_version_from_bundler_lock_file
    end

    def read_rails_version_from_bundler_lock_file
      lock_file_path = bundler_lock_file_path
      return nil unless lock_file_path

      File.foreach(lock_file_path) do |line|
        # If rails is in Gemfile.lock or gems.lock, there should be a line like:
        #         rails (X.X.X)
        result = line.match(/^\s+rails\s+\((\d+\.\d+)/)
        return result.captures.first.to_f if result
      end
    end

    def bundler_lock_file_path
      return nil unless loaded_path

      base_path = base_dir_for_path_parameters
      ['gems.locked', 'Gemfile.lock'].each do |file_name|
        path = find_file_upwards(file_name, base_path)
        return path if path
      end
      nil
    end

    def reject_mutually_exclusive_defaults
      disabled_by_default = for_all_cops['DisabledByDefault']
      enabled_by_default = for_all_cops['EnabledByDefault']
      return unless disabled_by_default && enabled_by_default

      msg = 'Cops cannot be both enabled by default and disabled by default'
      raise ValidationError, msg
    end

    def enable_cop?(qualified_cop_name, cop_options)
      cop_department, cop_name = qualified_cop_name.split('/')
      department = cop_name.nil?

      unless department
        department_options = self[cop_department]
        if department_options && department_options['Enabled'] == false
          return false
        end
      end

      cop_options.fetch('Enabled', true)
    end

    def smart_loaded_path
      PathUtil.smart_path(@loaded_path)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
