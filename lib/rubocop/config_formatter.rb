# frozen_string_literal: true

require 'yaml'

module RuboCop
  # Builds YAML config file from two hashes
  class ConfigFormatter
    DEPARTMENTS = /^(#{Cop::Cop.registry.departments.join('|')})/x.freeze
    STANDALONE_DEPARTMENT_EXCLUSIONS = ['Rails'].freeze

    def initialize(config, descriptions)
      @config = config
      @descriptions = descriptions
    end

    def dump
      YAML.dump(unified_config).gsub(DEPARTMENTS, "\n\\1")
    end

    private

    def unified_config
      cops.each_with_object(config.dup) do |cop, unified|
        unified[cop] = config.fetch(cop).merge(descriptions.fetch(cop))
      end
    end

    def cops
      (descriptions.keys | config.keys).grep(DEPARTMENTS) -
        STANDALONE_DEPARTMENT_EXCLUSIONS
    end

    attr_reader :config, :descriptions
  end
end
