# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def inspect(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            if line =~ /\r$/
              add_offence(:convention,
                          source_range(source_buffer, source[0...index],
                                       line.length - 1, 1),
                          MSG)
            end
          end
        end
      end
    end
  end
end
