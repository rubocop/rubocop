# frozen_string_literal: true

module RuboCop
  # This class handles obsolete configuration.
  # @api private
  class ConfigObsoletion
    DEFAULT_RULES_FILE = File.join(ConfigLoader::RUBOCOP_HOME, 'config', 'obsoletion.yml')
    COP_RULE_CLASSES = {
      'renamed' => RenamedCop,
      'removed' => RemovedCop,
      'split' => SplitCop,
      'extracted' => ExtractedCop
    }.freeze
    PARAMETER_RULE_CLASSES = {
      'changed_parameters' => ChangedParameter,
      'changed_enforced_styles' => ChangedEnforcedStyles
    }.freeze

    attr_reader :rules, :warnings

    class << self
      attr_accessor :files

      def legacy_cop_names
        # Used by DepartmentName#qualified_legacy_cop_name
        new(Config.new).rules.select(&:cop_rule?).map(&:old_name)
      end
    end

    # Can be extended by extension libraries to add their own obsoletions
    self.files = [DEFAULT_RULES_FILE]

    def initialize(config)
      @config = config
      @rules = load_rules
      @warnings = []
    end

    def reject_obsolete!
      messages = obsoletions.flatten.compact
      return if messages.empty?

      raise ValidationError, messages.join("\n")
    end

    private

    # Default rules for obsoletions are in config/obsoletion.yml
    # Additional rules files can be added with `RuboCop::ConfigObsoletion.files << filename`
    def load_rules # rubocop:disable Metrics/AbcSize
      rules = self.class.files.each_with_object({}) do |filename, hash|
        hash.merge!(YAML.safe_load(File.read(filename))) do |_key, first, second|
          case first
          when Hash
            first.merge(second)
          when Array
            first.concat(second)
          end
        end
      end

      cop_rules = rules.slice(*COP_RULE_CLASSES.keys)
      parameter_rules = rules.slice(*PARAMETER_RULE_CLASSES.keys)

      load_cop_rules(cop_rules).concat(load_parameter_rules(parameter_rules))
    end

    # Cop rules are keyed by the name of the original cop
    def load_cop_rules(rules)
      rules.flat_map do |rule_type, data|
        data.map do |cop_name, configuration|
          next unless configuration # allow configurations to be disabled with `CopName: ~`

          COP_RULE_CLASSES[rule_type].new(@config, cop_name, configuration)
        end.compact
      end
    end

    # Parameter rules may apply to multiple cops and multiple parameters
    # and are given as an array. Each combination is turned into a separate
    # rule object.
    def load_parameter_rules(rules)
      rules.flat_map do |rule_type, data|
        data.flat_map do |configuration|
          cops = Array(configuration['cops'])
          parameters = Array(configuration['parameters'])

          cops.product(parameters).map do |cop, parameter|
            PARAMETER_RULE_CLASSES[rule_type].new(@config, cop, parameter, configuration)
          end
        end
      end
    end

    def obsoletions
      rules.map do |rule|
        next unless rule.violated?

        if rule.warning?
          @warnings.push(rule.message)
          next
        end

        rule.message
      end
    end
  end
end
