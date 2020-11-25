# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to ignore certain methods when
    # parsing.
    # Cops that use `IgnoredMethods` can accept either strings or regexes to match
    # against.
    module IgnoredMethods
      # Configuration for IgnoredMethods. It is added to classes that include
      # the module so that configuration can be set using the `ignored_methods`
      # class macro.
      module Config
        attr_accessor :deprecated_key

        def ignored_methods(**config)
          self.deprecated_key = config[:deprecated_key]
        end
      end

      def self.included(base)
        base.extend(Config)
      end

      def ignored_method?(name)
        ignored_methods.any? do |value|
          case value
          when Regexp
            value.match? String(name)
          else
            value == String(name)
          end
        end
      end

      def ignored_methods
        keys = %w[IgnoredMethods]
        keys << deprecated_key if deprecated_key

        cop_config.slice(*keys).values.reduce(&:concat)
      end

      private

      def deprecated_key
        return unless self.class.respond_to?(:deprecated_key)

        self.class.deprecated_key&.to_s
      end
    end
  end
end
