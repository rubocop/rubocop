# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class LineContinuation < Cop
        MSG = 'Avoid the use of the line continuation character(\).'

        def inspect(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            if line =~ /.*\\\z/
              add_offence(:convention,
                          Location.new(index + 1, line.length, source), MSG)
            end
          end
        end
      end
    end
  end
end
