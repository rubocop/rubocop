# encoding: utf-8

module Rubocop
  module Cop
    class Offence
      attr_accessor :severity, :line_number, :line, :message

      SEVERITIES = [:refactor, :convention, :warning, :error, :fatal]

      def initialize(severity, line_number, line, message)
        @severity = severity
        @line_number = line_number
        @line = line
        @message = message
      end

      def to_s
        "#{encode_severity}:#{sprintf("%3d", line_number)}: #{message}"
      end

      def encode_severity
        @severity.to_s[0].upcase
      end
    end
  end
end
