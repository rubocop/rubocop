# encoding: utf-8

module Rubocop
  module Cop
    # An Offence represents a style violation detected by RuboCop.
    class Offence
      # @api private
      SEVERITIES = [:refactor, :convention, :warning, :error, :fatal]

      # @!attribute [r] severity
      #
      # @return [Symbol]
      #   severity.
      #   any of `:refactor`, `:convention`, `:warning`, `:error` or `:fatal`.
      attr_reader :severity

      # @!attribute [r] line_number
      #
      # @return [Integer]
      #   the line which the violation is detected.
      #   first line is `1`.
      attr_reader :line_number

      # @!attribute [r] message
      #
      # @return [String]
      #   human-readable message
      #
      # @example
      #   'Line is too long. [90/79]'
      attr_reader :message

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
      def initialize(severity, line_number, message, cop_name)
        @severity = severity
        @line_number = line_number
        @message = message
        @cop_name = cop_name
      end

      # @api private
      def to_s
        # we must be wary of messages containing % in them
        sprintf("#{encode_severity}:%3d: #{message.gsub(/%/, '%%')}",
                line_number)
      end

      # @api private
      def encode_severity
        @severity.to_s[0].upcase
      end

      # @api public
      #
      # @return [Boolean]
      #   returns `true` if two offences contain same attributes
      def ==(other)
        severity == other.severity && line_number == other.line_number &&
          message == other.message && cop_name == other.cop_name
      end

      # @api private
      def explode
        [severity, line_number, message]
      end
    end
  end
end
