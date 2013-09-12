# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for trailing blank lines in the source code.
      class TrailingBlankLines < Cop
        MSG = '%d trailing blank lines detected.'

        def investigate(processed_source)
          blank_lines = 0

          processed_source.lines.reverse_each do |line|
            if line.blank?
              blank_lines += 1
            else
              break
            end
          end

          if blank_lines > 0
            convention(nil,
                       source_range(processed_source.buffer,
                                    processed_source[0...-blank_lines],
                                    0, 1),
                       format(MSG, blank_lines))
          end
        end
      end
    end
  end
end
