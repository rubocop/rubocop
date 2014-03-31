# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for tabs inside the source code.
      class Tab < Cop
        MSG = 'Tab detected.'
        DEFAULT_TAB_WIDTH = 2

        def tab_width
          @tab_width ||= (cop_config &&
                          cop_config['TabWidth'] ||
                          DEFAULT_TAB_WIDTH).to_i
        end

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            match = line.match(/^( *)\t/)
            if match
              spaces = match.captures[0]

              begin_pos = spaces.length

              while (tab_match = line[begin_pos..-1].match(/^(\t *)/))
                tab_and_spaces = tab_match.captures[0]
                range = source_range(processed_source.buffer,
                                     processed_source[0...index],
                                     begin_pos, 1)
                # add one offense for each ysn
                add_offense(range, range, MSG)
                begin_pos += tab_and_spaces.length
              end
            end
          end
        end

        private

        def autocorrect(range)
          @corrections << lambda do |corrector|
            # replace tab with spaces
            corrector.replace(range, ' ' * tab_width)
          end
        end
      end
    end
  end
end
