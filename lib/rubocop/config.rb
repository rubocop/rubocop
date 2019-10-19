# frozen_string_literal: true

require 'pathname'

module RuboCop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class Config
    include PathUtil
    include FileFinder
    extend Forwardable

    DEFAULT_RAILS_VERSION = 5.0
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
      @validator = ConfigValidator.new(self)
    end

    def self.create(hash, path)
      new(hash, path).check
    end

    def check
      deprecation_check do |deprecation_message|
        warn("#{loaded_path} - #{deprecation_message}")
      end
      @validator.validate
      make_excludes_absolute
      self
    end

    def_delegators :@hash, :[], :[]=, :delete, :each, :key?, :keys, :each_key,
                   :map, :merge, :to_h, :to_hash
    def_delegators :@validator, :validate, :target_ruby_version

    def to_s
      @to_s ||= @hash.to_s
    end

    def signature
      @signature ||= Digest::SHA1.hexdigest(to_s)
    end

    # True if this is a config file that is shipped with RuboCop
    def internal?
      base_config_path = File.expand_path(File.join(ConfigLoader::RUBOCOP_HOME,
                                                    'config'))
      File.expand_path(loaded_path).start_with?(base_config_path)
    end

    def make_excludes_absolute
      each_key do |key|
        @validator.validate_section_presence(key)
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

    def for_department(department_name)
      @for_cop[department_name]
    end

    def for_all_cops
      @for_all_cops ||= self['AllCops'] || {}
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

    def smart_loaded_path
      PathUtil.smart_path(@loaded_path)
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

    private

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

    def enable_cop?(qualified_cop_name, cop_options)
      cop_department, cop_name = qualified_cop_name.split('/')
      department = cop_name.nil?

      unless department
        department_options = self[cop_department]
        if department_options && department_options['Enabled'] == false
          return false
        end
      end

      cop_options.fetch('Enabled') { !for_all_cops['DisabledByDefault'] }
    end
  end
end
