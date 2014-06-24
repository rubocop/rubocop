# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        MSG = 'Carriage return character detected.'

        def investigate(processed_source)
          buffer = processed_source.buffer
          original_source = IO.read(buffer.name, encoding: 'ascii-8bit')
          change_encoding(original_source)

          original_source.lines.each_with_index do |line, index|
            next unless line =~ /\r$/

            range = source_range(buffer, index + 1, 0, line.length)
            add_offense(nil, range, MSG)
            # Usually there will be carriage return characters on all or none
            # of the lines in a file, so we report only one offense.
            break
          end
        end

        private

        def change_encoding(string)
          recognized_encoding =
            Parser::Source::Buffer.recognize_encoding(string)
          string.force_encoding(recognized_encoding) if recognized_encoding
        end
      end
    end
  end
end
