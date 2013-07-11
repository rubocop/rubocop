# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for trailing whitespace in the source code.
      class TrailingWhitespace < Cop
        MSG = 'Trailing whitespace detected.'

        def investigate(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            if line =~ /.*[ \t]+$/
              add_offence(:convention,
                          source_range(source_buffer, source[0...index],
                                       line.rstrip.length,
                                       line.length - line.rstrip.length),
                          MSG)
            end
          end
        end
      end
    end
  end
end
