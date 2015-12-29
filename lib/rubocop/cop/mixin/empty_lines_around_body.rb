# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Common functionality for checking if presence/absence of empty lines
      # around some kind of body matches the configuration.
      module EmptyLinesAroundBody
        include ConfigurableEnforcedStyle

        MSG_EXTRA = 'Extra empty line detected at %s body %s.'
        MSG_MISSING = 'Empty line missing at %s body %s.'

        def autocorrect(range)
          lambda do |corrector|
            if range.source == "\n"
              corrector.remove(range)
            else
              corrector.insert_before(range, "\n")
            end
          end
        end

        private

        def check(node)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          check_source(node, start_line, end_line)
        end

        def check_source(node, start_line, end_line)
          case style
          when :no_empty_lines
            check_for_empty_lines(start_line, end_line)
          when :empty_lines
            check_for_nonempty_lines(start_line, end_line)
          when :top_level_only
            if node.top_level?
              check_for_nonempty_lines(start_line, end_line)
            else
              check_for_empty_lines(start_line, end_line)
            end
          when :body_start_only
            check_for_leading_nonempty_line(start_line, end_line)
          end
        end

        def check_for_empty_lines(start_line, end_line)
          check_start(start_line, MSG_EXTRA, 1, &:empty?)
          check_end(end_line - 2, MSG_EXTRA, 1, &:empty?)
        end

        def check_for_nonempty_lines(start_line, end_line)
          check_start(start_line, MSG_MISSING, 1) { |line| !line.empty? }
          check_end(end_line - 2, MSG_MISSING, 2) { |line| !line.empty? }
        end

        def check_for_leading_nonempty_line(start_line, end_line)
          check_start(start_line, MSG_MISSING, 1) { |line| !line.empty? }
          check_end(end_line - 2, MSG_EXTRA, 1, &:empty?)
        end

        def check_start(line, msg, offset, &block)
          msg = format(msg, self.class::KIND, 'beginning')
          check_line(line, msg, offset, &block)
        end

        def check_end(line, msg, offset, &block)
          msg = format(msg, self.class::KIND, 'end')
          check_line(line, msg, offset, &block)
        end

        def check_line(line, msg, offset)
          return unless yield processed_source.lines[line]
          range = source_range(processed_source.buffer, line + offset, 0)
          add_offense(range, range, msg)
        end
      end
    end
  end
end
