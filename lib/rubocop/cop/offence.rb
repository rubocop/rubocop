# encoding: utf-8

module Rubocop
  module Cop
    class Offence
      attr_accessor :severity, :line_number, :message

      SEVERITIES = [:refactor, :convention, :warning, :error, :fatal]

      def initialize(severity, line_number, message)
        @severity = severity
        @line_number = line_number
        @message = message
      end

      def to_s
        # we must be wary of messages containing % in them
        sprintf("#{encode_severity}:%3d: #{message.gsub(/%/, '%%')}",
                line_number)
      end

      def encode_severity
        @severity.to_s[0].upcase
      end

      def ==(other)
        severity == other.severity and line_number == other.line_number and
          message == other.message
      end

      def explode
        [severity, line_number, message]
      end
    end
  end
end
