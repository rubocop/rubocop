# frozen_string_literal: true

module RuboCop
  # Defines common functionality for extending a ruleset using multiple
  # YAML configuration files (eg. for `ConfigObsoletion` rules to be added
  # from extensions).
  module ExtendableRules
    def self.included(base)
      base.class_eval do
        class << self
          # @api private
          attr_accessor :files, :load_rules_cache
        end
      end
    end

    protected

    def load_rules
      load_rules_cache[self.class.files] ||=
        self.class.files.each_with_object({}) do |filename, hash|
          hash.merge!(YAML.safe_load(File.read(filename)) || {}) do |_key, first, second|
            case first
            when Hash
              first.merge(second)
            when Array
              first.concat(second)
            end
          end
        end
    end

    def load_rules_cache
      self.class.load_rules_cache ||= {}
    end
  end
end
