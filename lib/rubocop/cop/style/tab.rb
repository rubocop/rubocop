# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for tabs inside the source code.
      class Tab < Cop
        MSG = 'Tab detected.'

        def investigate(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            match = line.match(/^( *)\t/)
            if match
              spaces = match.captures[0]
              add_offence(:convention,
                          source_range(source_buffer, source[0...index],
                                       spaces.length, 8),
                          MSG)
            end
          end
        end
      end
    end
  end
end
