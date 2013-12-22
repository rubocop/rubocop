# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the length of lines in the source code.
      # The maximum length is configurable.
      class LineLength < Cop
        include ConfigurableMax

        MSG = 'Line is too long. [%d/%d]'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            if line.length > max
              message = sprintf(MSG, line.length, max)
              add_offence(nil,
                          source_range(processed_source.buffer,
                                       processed_source[0...index], max,
                                       line.length - max),
                          message) do
                self.max = line.length
              end
            end
          end
        end

        def max
          cop_config['Max']
        end
      end
    end
  end
end
