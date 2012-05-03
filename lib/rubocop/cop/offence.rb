module Rubocop
  module Cop
    class Offence
      attr_accessor :filename, :line_number, :line, :message

      def initialize(filename, line_number, line, message)
        @filename = filename
        @line_number = line_number
        @line = line
        @message = message
      end

      def to_s
        "#@filename:#@line_number:#{@line.chomp} - #@message"
      end
    end
  end
end
