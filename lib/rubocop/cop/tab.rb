module Rubocop
  module Cop
    class Tab < Cop
      ERROR_MESSAGE = 'Tab detected.'

      def inspect(file, source)
        source.each_with_index do |line, index|
          if line =~ /^ *\t/
            add_offence(:convention, index, line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
