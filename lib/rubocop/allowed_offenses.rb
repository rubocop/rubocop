# frozen_string_literal: true

module RuboCop
  # Tracks per-cop offense allowances across a run.
  # @api private
  class AllowedOffenses
    def initialize(config)
      @config = config
      @configured = config.to_h.any? do |name, cop_config|
        name != 'AllCops' && cop_config.is_a?(Hash) && cop_config.key?('AllowedOffenses')
      end
      @limits = {}
      @counts = Hash.new(0)
    end

    def configured?
      @configured
    end

    def configured_for?(cop_name)
      !limits_for(cop_name).nil?
    end

    def record(file, offenses)
      file_path = normalized_file_path(file)

      offenses.each do |offense|
        next if offense.disabled? || offense.corrected?
        next unless configured_for?(offense.cop_name)

        @counts[[offense.cop_name, file_path]] += 1
      end
    end

    def exceeded?
      @counts.any? do |(cop_name, file_path), count|
        count > limit_for(cop_name, file_path)
      end
    end

    def over_limit?(cop_name, file_path)
      @counts[[cop_name, file_path]] > limit_for(cop_name, file_path)
    end

    def filter(file, offenses)
      file_path = normalized_file_path(file)

      offenses.reject do |offense|
        configured_for?(offense.cop_name) && !over_limit?(offense.cop_name, file_path)
      end
    end

    private

    def limit_for(cop_name, file_path)
      limits_for(cop_name)&.fetch(file_path, 0)
    end

    def limits_for(cop_name)
      return @limits[cop_name] if @limits.key?(cop_name)

      @limits[cop_name] = cop_config(cop_name)['AllowedOffenses']
    end

    def normalized_file_path(file)
      base_dir = if @config.respond_to?(:base_dir_for_path_parameters)
                   @config.base_dir_for_path_parameters
                 else
                   PathUtil.pwd
                 end

      PathUtil.normalized_relative_path(file, base_dir)
    end

    def cop_config(cop_name)
      cop_class = Cop::Registry.global.find_by_cop_name(cop_name)
      return @config.for_badge(cop_class.badge) if cop_class && @config.respond_to?(:for_badge)
      return @config.for_cop(cop_name) if @config.respond_to?(:for_cop)

      department_config = @config.to_h[cop_name.split('/').first] || {}
      department_config.merge(@config.to_h[cop_name] || {})
    end
  end
end
