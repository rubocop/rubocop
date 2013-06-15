# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def inspect(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            if line =~ /\r$/
              add_offence(:convention,
                          Location.new(index + 1, line.length, source), MSG)
            end
          end
        end
      end
    end
  end
end
