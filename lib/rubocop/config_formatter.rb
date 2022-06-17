# frozen_string_literal: true

require 'yaml'

module RuboCop
  # Builds a YAML config file from two config hashes
  class ConfigFormatter
    # SUBDEPARTMENTS = %(RSpec/Capybara RSpec/FactoryBot RSpec/Rails)
    COP_DOC_BASE_URL = 'https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/'

    def initialize(config, descriptions)
      @config       = config
      @descriptions = descriptions
    end

    def dump
      YAML.dump(unified_config)
        .gsub(/^(\s+)- /, '\1  - ')
    end

    private

    def unified_config
      cops.each_with_object(config.dup) do |cop, unified|
        # next if SUBDEPARTMENTS.include?(cop)
        # next if AMENDMENTS.include?(cop)
        next if cop == 'AllCops'
        next if cop == 'Cop/Base'

        unified[cop].merge!(descriptions.fetch(cop)) rescue binding.pry
        unified[cop]['Reference'] = COP_DOC_BASE_URL + cop
      end
    end

    def cops
      descriptions.keys | config.keys
    end

    attr_reader :config, :descriptions
  end
end
