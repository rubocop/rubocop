# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for tabs inside the source code.
      class Tab < Cop
        MSG = 'Tab detected.'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            match = line.match(/^( *)[\t ]*\t/)
            next unless match

            spaces = match.captures[0]

            range = source_range(processed_source.buffer,
                                 index + 1,
                                 (spaces.length)...(match.end(0)))

            add_offense(range, range, MSG)
          end
        end

        private

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(range, range.source.gsub(/\t/, '  '))
          end
        end
      end
    end
  end
end
