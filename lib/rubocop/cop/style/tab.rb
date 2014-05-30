# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for tabs inside the source code.
      class Tab < Cop
        MSG = 'Tab detected.'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            match = line.match(/^( *)\t/)
            next unless match

            spaces = match.captures[0]
            add_offense(nil,
                        source_range(processed_source.buffer,
                                     processed_source[0...index],
                                     spaces.length, 1),
                        MSG)
          end
        end
      end
    end
  end
end
