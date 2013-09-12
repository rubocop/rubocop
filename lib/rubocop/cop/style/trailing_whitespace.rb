# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for trailing whitespace in the source code.
      class TrailingWhitespace < Cop
        MSG = 'Trailing whitespace detected.'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            if line =~ /.*[ \t]+$/
              convention(nil,
                         source_range(processed_source.buffer,
                                      processed_source[0...index],
                                      line.rstrip.length,
                                      line.length - line.rstrip.length))
            end
          end
        end
      end
    end
  end
end
