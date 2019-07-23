# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Handles validation of configuration, for example cop names, parameter
  # names, and Ruby versions.
  class ConfigValidator
    extend Forwardable

    COMMON_PARAMS = %w[Exclude Include Severity inherit_mode
                       AutoCorrect StyleGuide Details].freeze
    INTERNAL_PARAMS = %w[Description StyleGuide VersionAdded
                         VersionChanged Reference Safe SafeAutoCorrect].freeze

    # 2.3 is the oldest officially supported Ruby version.
    DEFAULT_RUBY_VERSION = 2.3
    KNOWN_RUBIES = [2.3, 2.4, 2.5, 2.6, 2.7].freeze
    OBSOLETE_RUBIES = {
      1.9 => '0.50', 2.0 => '0.50', 2.1 => '0.58', 2.2 => '0.69'
    }.freeze
    RUBY_VERSION_FILENAME = '.ruby-version'

    def_delegators :@config,
                   :smart_loaded_path, :for_all_cops, :find_file_upwards,
                   :base_dir_for_path_parameters, :bundler_lock_file_path

    def initialize(config)
      @config = config
      @config_obsoletion = ConfigObsoletion.new(config)
    end

    def validate
      # Don't validate RuboCop's own files. Avoids infinite recursion.
      base_config_path = File.expand_path(File.join(ConfigLoader::RUBOCOP_HOME,
                                                    'config'))
      return if File.expand_path(@config.loaded_path)
                    .start_with?(base_config_path)

      valid_cop_names, invalid_cop_names = @config.keys.partition do |key|
        ConfigLoader.default_configuration.key?(key)
      end

      @config_obsoletion.reject_obsolete_cops_and_parameters

      warn_about_unrecognized_cops(invalid_cop_names)
      check_target_ruby
      validate_parameter_names(valid_cop_names)
      validate_enforced_styles(valid_cop_names)
      validate_syntax_cop
      reject_mutually_exclusive_defaults
    end

    def target_ruby_version
      @target_ruby_version ||= begin
        if for_all_cops['TargetRubyVersion']
          @target_ruby_version_source = :rubocop_yml

          for_all_cops['TargetRubyVersion'].to_f
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
    end

    def validate_section_presence(name)
      return unless @config.key?(name) && @config[name].nil?

      raise ValidationError,
            "empty section #{name} found in #{smart_loaded_path}"
    end

    private

    def check_target_ruby
      return if KNOWN_RUBIES.include?(target_ruby_version)

      msg = if OBSOLETE_RUBIES.include?(target_ruby_version)
              "RuboCop found unsupported Ruby version #{target_ruby_version} " \
              "in #{target_ruby_source}. #{target_ruby_version}-compatible " \
              'analysis was dropped after version ' \
              "#{OBSOLETE_RUBIES[target_ruby_version]}."
            else
              'RuboCop found unknown Ruby version ' \
              "#{target_ruby_version.inspect} in #{target_ruby_source}."
            end

      msg += "\nSupported versions: #{KNOWN_RUBIES.join(', ')}"

      raise ValidationError, msg
    end

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
      syntax_config = @config['Lint/Syntax']
      default_config = ConfigLoader.default_configuration['Lint/Syntax']

      return unless syntax_config &&
                    default_config.merge(syntax_config) != default_config

      raise ValidationError,
            "configuration for Syntax cop found in #{smart_loaded_path}\n" \
            'It\'s not possible to disable this cop.'
    end

    def validate_parameter_names(valid_cop_names)
      valid_cop_names.each do |name|
        validate_section_presence(name)
        default_config = ConfigLoader.default_configuration[name]

        @config[name].each_key do |param|
          next if COMMON_PARAMS.include?(param) || default_config.key?(param)

          message =
            "Warning: #{name} does not support #{param} parameter.\n\n" \
            "Supported parameters are:\n\n" \
            "  - #{(default_config.keys - INTERNAL_PARAMS).join("\n  - ")}\n"

          warn Rainbow(message).yellow.to_s
        end
      end
    end

    def validate_enforced_styles(valid_cop_names)
      valid_cop_names.each do |name|
        styles = @config[name].select { |key, _| key.start_with?('Enforced') }

        styles.each do |style_name, style|
          supported_key = RuboCop::Cop::Util.to_supported_styles(style_name)
          valid = ConfigLoader.default_configuration[name][supported_key]

          next unless valid
          next if valid.include?(style)
          next if validate_support_and_has_list(name, style, valid)

          msg = "invalid #{style_name} '#{style}' for #{name} found in " \
            "#{smart_loaded_path}\n" \
            "Valid choices are: #{valid.join(', ')}"
          raise ValidationError, msg
        end
      end
    end

    def validate_support_and_has_list(name, formats, valid)
      ConfigLoader.default_configuration[name]['AllowMultipleStyles'] &&
        formats.is_a?(Array) &&
        formats.all? { |format| valid.include?(format) }
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

    def reject_mutually_exclusive_defaults
      disabled_by_default = for_all_cops['DisabledByDefault']
      enabled_by_default = for_all_cops['EnabledByDefault']
      return unless disabled_by_default && enabled_by_default

      msg = 'Cops cannot be both enabled by default and disabled by default'
      raise ValidationError, msg
    end
  end
end
