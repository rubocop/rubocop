# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def investigate(processed_source)
          buffer = processed_source.buffer
          original_source = IO.read(buffer.name,
                                    encoding: buffer.source.encoding)
          original_source.lines.each_with_index do |line, index|
            if line =~ /\r$/
              add_offence(nil,
                          source_range(buffer,
                                       processed_source[0...index],
                                       0, line.length),
                          MSG)
              # Usually there will be carriage return characters on all or none
              # of the lines in a file, so we report only one offence.
              break
            end
          end
        end
      end
    end
  end
end
