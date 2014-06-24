# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the length of lines in the source code.
      # The maximum length is configurable.
      class LineLength < Cop
        include ConfigurableMax

        MSG = 'Line is too long. [%d/%d]'

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            next unless line.length > max

            message = format(MSG, line.length, max)

            range = source_range(processed_source.buffer,
                                 index + 1,
                                 max...(line.length))

            add_offense(nil, range, message) do
              self.max = line.length
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
