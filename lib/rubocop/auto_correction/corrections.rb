# encoding: utf-8

module Rubocop
  # rubocop:disable Documentation
  # TODO: There is a bug in the Documentation cop
  # for modules that contain class and then a singleton definition.
  module AutoCorrection
    # Class that holds the corrections
    class Corrections
      def initialize
        @corrections = {}
      end

      def register(cop_name, correction_class)
        @corrections[cop_name] = correction_class
      end

      def all
        @corrections.reduce({}) do |hash, (cop_name, correction_class)|
          hash[cop_name] = correction_class.new
          hash
        end
      end
    end

    # Global singleton that holds all registered corrections.
    # Only correction that are registered via `Registry.register`
    # will be invoked on auto-correction.
    Registry = Corrections.new
  end
end
