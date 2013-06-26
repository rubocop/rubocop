# encoding: utf-8

module Rubocop
  module Cop
    # A Location represents a place where the violation is detected in a file.
    class Location
      # @api public
      #
      # @!attribute [r] line
      #
      # @return [Integer]
      #   the line number.
      #   first line is `1`.
      attr_reader :line

      # @api public
      #
      # @!attribute [r] column
      #
      # @return [Integer]
      #   the column number.
      #   beginning of line is `0`.
      attr_reader :column

      # @api public
      #
      # @!attribute [r] source_line
      #
      # @return [String]
      #   the source code line where the offence occurred.
      attr_reader :source_line

      # @api private
      def initialize(line, column, source)
        @line = line.freeze
        @column = column.freeze
        @source_line = source[line - 1].freeze
        freeze
      end

      # @api private
      #
      # Internally we use column number that start at 0, but when
      # outputting column numbers, we want them to start at 1. One
      # reason is that editors, such as Emacs, expect this.
      def real_column
        column + 1
      end
    end

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
      # @return [Rubocop::Cop::Location]
      #   the location where the violation is detected.
      #
      # @see Rubocop::Cop::Location
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
        # we must be wary of messages containing % in them
        sprintf("#{encode_severity}:%3d:%3d: #{message.gsub(/%/, '%%')}",
                line, real_column)
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

      # @api private
      def explode
        [severity, line, column, message]
      end
    end
  end
end
