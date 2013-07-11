# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the length of lines in the source code.
      # The maximum length is configurable.
      class LineLength < Cop
        MSG = 'Line is too long. [%d/%d]'

        def investigate(source_buffer, source, tokens, ast, comments)
          source.each_with_index do |line, index|
            max = LineLength.max
            if line.length > max
              message = sprintf(MSG, line.length, max)
              add_offence(:convention,
                          source_range(source_buffer, source[0...index], max,
                                       line.length - max),
                          message)
            end
          end
        end

        def self.max
          LineLength.config['Max']
        end
      end
    end
  end
end
