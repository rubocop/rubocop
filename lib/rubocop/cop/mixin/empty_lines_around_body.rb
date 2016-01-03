# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Common functionality for checking if presence/absence of empty lines
      # around some kind of body matches the configuration.
      module EmptyLinesAroundBody
        include ConfigurableEnforcedStyle

        MSG_EXTRA = 'Extra empty line detected at %s body %s.'.freeze
        MSG_MISSING = 'Empty line missing at %s body %s.'.freeze

        def autocorrect(range)
          lambda do |corrector|
            case style
            when :no_empty_lines then corrector.remove(range)
            when :empty_lines    then corrector.insert_before(range, "\n")
            end
          end
        end

        private

        def check(node, body)
          # When style is `empty_lines`, if the body is empty, we don't enforce
          # the presence OR absence of an empty line
          # But if style is `no_empty_lines`, there must not be an empty line
          return unless body || style == :no_empty_lines

          start_line = node.loc.keyword.line
          end_line = node.loc.end.line
          return if start_line == end_line

          check_source(start_line, end_line)
        end

        def check_source(start_line, end_line)
          case style
          when :no_empty_lines
            check_both(start_line, end_line, MSG_EXTRA, &:empty?)
          when :empty_lines
            check_both(start_line, end_line, MSG_MISSING) do |line|
              !line.empty?
            end
          end
        end

        def check_both(start_line, end_line, msg, &block)
          kind = self.class::KIND
          check_line(start_line, format(msg, kind, 'beginning'), &block)
          check_line(end_line - 2, format(msg, kind, 'end'), &block)
        end

        def check_line(line, msg)
          return unless yield processed_source.lines[line]

          offset = style == :empty_lines && msg.include?('end.') ? 2 : 1
          range = source_range(processed_source.buffer, line + offset, 0)
          add_offense(range, range, msg)
        end
      end
    end
  end
end
