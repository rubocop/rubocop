module Rubocop
  module Cop
    class LineLengthCop < Cop
      def inspect(file)
        File.readlines(file).each_with_index do |line, index|
          add_offence(file, index, line, "Line too long") if line.size > 80
        end
      end
    end
  end
end
