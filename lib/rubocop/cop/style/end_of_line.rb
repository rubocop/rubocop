# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            if line =~ /\r$/
              convention(nil,
                         source_range(processed_source.buffer,
                                      processed_source[0...index],
                                      line.length - 1, 1),
                         MSG)
            end
          end
        end
      end
    end
  end
end
