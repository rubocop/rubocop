# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the line continuation character.
      #
      # This check has to be refined or retired, since it doesn't make a lot
      # of sense without inspection of its context.
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
