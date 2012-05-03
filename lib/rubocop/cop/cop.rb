module Rubocop
  module Cop
    class Cop
      attr_accessor :offences

      def initialize
        @offences = []
      end

      def report
        @offences.each do |offence|
          puts offence
        end
      end

      def add_offence(file, line_number, line, message)
        @offences << Offence.new(file, line_number, line, message)
      end
    end
  end
end
