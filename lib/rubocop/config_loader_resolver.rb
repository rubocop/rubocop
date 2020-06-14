# frozen_string_literal: true

require 'yaml'
require 'pathname'

module RuboCop
  # A help class for ConfigLoader that handles configuration resolution.
  class ConfigLoaderResolver
    def resolve_requires(path, hash)
      config_dir = File.dirname(path)
      Array(hash.delete('require')).each do |r|
        if r.start_with?('.')
          require(File.join(config_dir, r))
        else
          require(r)
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def resolve_inheritance(path, hash, file, debug)
      inherited_files = Array(hash['inherit_from'])
      base_configs(path, inherited_files, file)
        .reverse.each_with_index do |base_config, index|
        override_department_setting_for_cops(base_config, hash)
        base_config.each do |k, v|
          next unless v.is_a?(Hash)

          if hash.key?(k)
            v = merge(v, hash[k],
                      cop_name: k, file: file, debug: debug,
                      inherited_file: inherited_files[index],
                      inherit_mode: determine_inherit_mode(hash, k))
          end
          hash[k] = v
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def resolve_inheritance_from_gems(hash)
      gems = hash.delete('inherit_gem')
      (gems || {}).each_pair do |gem_name, config_path|
        if gem_name == 'rubocop'
          raise ArgumentError,
                "can't inherit configuration from the rubocop gem"
        end

        hash['inherit_from'] = Array(hash['inherit_from'])
        Array(config_path).reverse_each do |path|
          # Put gem configuration first so local configuration overrides it.
          hash['inherit_from'].unshift gem_config_path(gem_name, path)
        end
      end
    end

    # Merges the given configuration with the default one. If
    # AllCops:DisabledByDefault is true, it changes the Enabled params so that
    # only cops from user configuration are enabled. If
    # AllCops::EnabledByDefault is true, it changes the Enabled params so that
    # only cops explicitly disabled in user configuration are disabled.
    def merge_with_default(config, config_file, unset_nil:)
      default_configuration = ConfigLoader.default_configuration

      disabled_by_default = config.for_all_cops['DisabledByDefault']
      enabled_by_default = config.for_all_cops['EnabledByDefault']

      if disabled_by_default || enabled_by_default
        default_configuration = transform(default_configuration) do |params|
          params.merge('Enabled' => !disabled_by_default)
        end
      end

      config = handle_disabled_by_default(config, default_configuration) if disabled_by_default

      opts = { inherit_mode: config['inherit_mode'] || {},
               unset_nil: unset_nil }
      Config.new(merge(default_configuration, config, **opts), config_file)
    end

    # Return a recursive merge of two hashes. That is, a normal hash merge,
    # with the addition that any value that is a hash, and occurs in both
    # arguments, will also be merged. And so on.
    #
    # rubocop:disable Metrics/AbcSize
    def merge(base_hash, derived_hash, **opts)
      result = base_hash.merge(derived_hash)
      keys_appearing_in_both = base_hash.keys & derived_hash.keys
      keys_appearing_in_both.each do |key|
        if opts[:unset_nil] && derived_hash[key].nil?
          result.delete(key)
        elsif base_hash[key].is_a?(Hash)
          result[key] = merge(base_hash[key], derived_hash[key], **opts)
        elsif should_union?(base_hash, key, opts[:inherit_mode])
          result[key] = base_hash[key] | derived_hash[key]
        elsif opts[:debug]
          warn_on_duplicate_setting(base_hash, derived_hash, key, **opts)
        end
      end
      result
    end
    # rubocop:enable Metrics/AbcSize

    # An `Enabled: true` setting in user configuration for a cop overrides an
    # `Enabled: false` setting for its department.
    def override_department_setting_for_cops(base_hash, derived_hash)
      derived_hash.each_key do |key|
        next unless key =~ %r{(.*)/.*}

        department = Regexp.last_match(1)
        next unless disabled?(derived_hash, department) ||
                    disabled?(base_hash, department)

        # The `override_department` setting for the `Enabled` parameter is an
        # internal setting that's not documented in the manual. It will cause a
        # cop to be enabled later, when logic surrounding enabled/disabled it
        # run, even though its department is disabled.
        derived_hash[key]['Enabled'] = 'override_department' if derived_hash[key]['Enabled']
      end
    end

    private

    def disabled?(hash, department)
      hash[department] && hash[department]['Enabled'] == false
    end

    def duplicate_setting?(base_hash, derived_hash, key, inherited_file)
      return false if inherited_file.nil? # Not inheritance resolving merge
      return false if inherited_file.start_with?('..') # Legitimate override
      return false if base_hash[key] == derived_hash[key] # Same value
      return false if remote_file?(inherited_file) # Can't change

      Gem.path.none? { |dir| inherited_file.start_with?(dir) } # Can change?
    end

    def warn_on_duplicate_setting(base_hash, derived_hash, key, **opts)
      return unless duplicate_setting?(base_hash, derived_hash,
                                       key, opts[:inherited_file])

      inherit_mode = opts[:inherit_mode]['merge'] ||
                     opts[:inherit_mode]['override']
      return if base_hash[key].is_a?(Array) &&
                inherit_mode && inherit_mode.include?(key)

      puts "#{PathUtil.smart_path(opts[:file])}: " \
           "#{opts[:cop_name]}:#{key} overrides " \
           "the same parameter in #{opts[:inherited_file]}"
    end

    def determine_inherit_mode(hash, key)
      cop_cfg = hash[key]
      local_inherit = cop_cfg.delete('inherit_mode') if cop_cfg.is_a?(Hash)
      local_inherit || hash['inherit_mode'] || {}
    end

    def should_union?(base_hash, key, inherit_mode)
      base_hash[key].is_a?(Array) &&
        inherit_mode &&
        inherit_mode['merge'] &&
        inherit_mode['merge'].include?(key)
    end

    def base_configs(path, inherit_from, file)
      configs = Array(inherit_from).compact.map do |f|
        ConfigLoader.load_file(inherited_file(path, f, file))
      end

      configs.compact
    end

    def inherited_file(path, inherit_from, file)
      if remote_file?(inherit_from)
        # A remote configuration, e.g. `inherit_from: http://example.com/rubocop.yml`.
        RemoteConfig.new(inherit_from, File.dirname(path))
      elsif Pathname.new(inherit_from).absolute?
        # An absolute path to a config, e.g. `inherit_from: /Users/me/rubocop.yml`.
        # The path may come from `inherit_gem` option, where a gem name is expanded
        # to an absolute path to that gem.
        print 'Inheriting ' if ConfigLoader.debug?
        inherit_from
      elsif file.is_a?(RemoteConfig)
        # A path relative to a URL, e.g. `inherit_from: configs/default.yml`
        # in a config included with `inherit_from: http://example.com/rubocop.yml`
        file.inherit_from_remote(inherit_from, path)
      else
        # A local relative path, e.g. `inherit_from: default.yml`
        print 'Inheriting ' if ConfigLoader.debug?
        File.expand_path(inherit_from, File.dirname(path))
      end
    end

    def remote_file?(uri)
      regex = URI::DEFAULT_PARSER.make_regexp(%w[http https])
      /\A#{regex}\z/.match?(uri)
    end

    def handle_disabled_by_default(config, new_default_configuration)
      department_config = config.to_hash.reject { |cop| cop.include?('/') }
      department_config.each do |dept, dept_params|
        next unless dept_params['Enabled']

        new_default_configuration.each do |cop, params|
          next unless cop.start_with?(dept + '/')

          # Retain original default configuration for cops in the department.
          params['Enabled'] = ConfigLoader.default_configuration[cop]['Enabled']
        end
      end

      transform(config) do |params|
        { 'Enabled' => true }.merge(params) # Set true if not set.
      end
    end

    def transform(config)
      config.transform_values { |params| yield(params) }
    end

    def gem_config_path(gem_name, relative_config_path)
      if defined?(Bundler)
        gem = Bundler.load.specs[gem_name].first
        gem_path = gem.full_gem_path if gem
      end

      gem_path ||= Gem::Specification.find_by_name(gem_name).gem_dir

      File.join(gem_path, relative_config_path)
    rescue Gem::LoadError => e
      raise Gem::LoadError,
            "Unable to find gem #{gem_name}; is the gem installed? #{e}"
    end
  end
end
