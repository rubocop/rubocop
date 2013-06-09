# encoding: utf-8

module Rubocop
  module Cop
    # An Offence represents a style violation detected by RuboCop.
    class Offence
      # @api private
      SEVERITIES = [:refactor, :convention, :warning, :error, :fatal]

      # @api public
      #
      # @!attribute [r] severity
      #
      # @return [Symbol]
      #   severity.
      #   any of `:refactor`, `:convention`, `:warning`, `:error` or `:fatal`.
      attr_reader :severity

      # @api public
      #
      # @!attribute [r] location
      #
      # @return [Integer]
      #   the location where the violation is detected.
      attr_reader :location

      # @api public
      #
      # @!attribute [r] message
      #
      # @return [String]
      #   human-readable message
      #
      # @example
      #   'Line is too long. [90/79]'
      attr_reader :message

      # @api public
      #
      # @!attribute [r] cop_name
      #
      # @return [String]
      #   a cop class name without namespace.
      #   i.e. type of the violation.
      #
      # @example
      #   'LineLength'
      attr_reader :cop_name

      # @api private
      def initialize(severity, location, message, cop_name)
        unless SEVERITIES.include?(severity)
          fail ArgumentError, "Unknown severity: #{severity}"
        end
        @severity = severity
        @location = location
        @message = message
        @cop_name = cop_name
      end

      # @api private
      def line
        @location.line
      end

      # @api private
      def column
        @location.column
      end

      # @api private
      def to_s
        # we must be wary of messages containing % in them
        sprintf("#{encode_severity}:%3d:%3d: #{message.gsub(/%/, '%%')}",
                line, column)
      end

      # @api private
      def encode_severity
        @severity.to_s[0].upcase
      end

      # @api private
      def severity_level
        SEVERITIES.index(severity) + 1
      end

      # @api public
      #
      # @return [Boolean]
      #   returns `true` if two offences contain same attributes
      def ==(other)
        severity == other.severity && line == other.line &&
          column == other.column && message == other.message &&
          cop_name == other.cop_name
      end

      # @api private
      def explode
        [severity, line, column, message]
      end
    end
  end
end
