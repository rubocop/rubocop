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

      def register(cop_name, correction)
        @corrections[cop_name] = correction
      end

      def all
        @corrections
      end
    end

    # Global singleton that holds all registered corrections.
    # Only correction that are registered via `Registry.register`
    # will be invoked on auto-correction.
    Registry = Corrections.new
  end
end
