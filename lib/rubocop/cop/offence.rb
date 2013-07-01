# encoding: utf-8

module Rubocop
  module Cop
    # An Offence represents a style violation detected by RuboCop.
    class Offence
      include Comparable

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
      # @return [Parser::Source::Range]
      #   the location where the violation is detected.
      #
      # @see http://rubydoc.info/github/whitequark/parser/Parser/Source/Range
      #   Parser::Source::Range
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
      attr_reader :line

      # @api private
      attr_reader :column

      # @api private
      def initialize(severity, location, message, cop_name)
        unless SEVERITIES.include?(severity)
          fail ArgumentError, "Unknown severity: #{severity}"
        end
        @severity = severity.freeze
        @location = location.freeze
        @line = location.line.freeze
        @column = location.column.freeze
        @message = message.freeze
        @cop_name = cop_name.freeze
        freeze
      end

      # @api private
      def to_s
        sprintf("#{encode_severity}:%3d:%3d: %s",
                line, real_column, message)
      end

      # @api private
      def encode_severity
        @severity.to_s[0].upcase
      end

      # @api private
      def severity_level
        SEVERITIES.index(severity) + 1
      end

      # @api private
      #
      # Internally we use column number that start at 0, but when
      # outputting column numbers, we want them to start at 1. One
      # reason is that editors, such as Emacs, expect this.
      def real_column
        column + 1
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

      # @api public
      #
      # Returns `-1`, `0` or `+1`
      # if this offence is less than, equal to, or greater than `other`.
      #
      # @return [Integer]
      #   comparison result
      def <=>(other)
        [:line, :column, :cop_name, :message].each do |attribute|
          result = send(attribute) <=> other.send(attribute)
          return result unless result == 0
        end
        0
      end
    end
  end
end
