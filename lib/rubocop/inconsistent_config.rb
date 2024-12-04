# frozen_string_literal: true

module RuboCop
  # This class handles detecting configuration values that are inconsistent.
  # @api private
  class InconsistentConfig
    include ExtendableRules

    DEFAULT_RULES_FILE = File.join(ConfigLoader::RUBOCOP_HOME, 'config', 'inconsistent_config.yml')
    self.files = [DEFAULT_RULES_FILE]

    attr_reader :rules, :warnings

    def initialize(config)
      @config = config
      @rules = load_rules
      @warnings = []
    end

    def validate!
      rules.each do |rule|
        @warnings.push(warning_message(rule)) unless all_consistent?(rule)
      end
    end

    private

    def load_rules
      super.filter_map do |_name, rules|
        enabled_rules = rules['rules'].filter_map do |rule|
          config = @config.for_cop(rule['cop'])
          next unless config['Enabled']

          value = config[rule['parameter']]
          next if value.nil?

          rule.clone.tap { |r| r['value'] = value }
        end

        next if enabled_rules.empty?

        { 'rules' => enabled_rules, 'message' => rules['message'] }
      end
    end

    def all_consistent?(rule)
      rule['rules'].uniq { |r| r['value'] }.size == 1
    end

    def warning_message(rule)
      message = rule['rules'].map { |r| rule_value(r) }.join(' is inconsistent with ')
      message += "\n#{rule['message']}" if rule['message']
      message
    end

    def rule_value(configuration)
      "`#{configuration['cop']}` value for " \
        "`#{configuration['parameter']}` (#{configuration['value']})"
    end
  end
end
