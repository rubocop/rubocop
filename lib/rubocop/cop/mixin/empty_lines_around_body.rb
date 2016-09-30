# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Common functionality for checking if presence/absence of empty lines
      # around some kind of body matches the configuration.
      module EmptyLinesAroundBody
        extend NodePattern::Macros
        include ConfigurableEnforcedStyle

        MSG_EXTRA = 'Extra empty line detected at %s body %s.'.freeze
        MSG_MISSING = 'Empty line missing at %s body %s.'.freeze

        def_node_matcher :constant_definition?, '{class module}'

        def autocorrect(args)
          offence_style, range = args
          lambda do |corrector|
            case offence_style
            when :no_empty_lines then
              corrector.remove(range)
            when :empty_lines then
              corrector.insert_before(range, "\n")
            end
          end
        end

        private

        def check(node, body)
          # When style is `empty_lines`, if the body is empty, we don't enforce
          # the presence OR absence of an empty line
          # But if style is `no_empty_lines`, there must not be an empty line
          return unless body || style == :no_empty_lines
          return if node.single_line?

          first_line = node.source_range.first_line
          last_line = node.source_range.last_line

          case style
          when :empty_lines_except_namespace
            if namespace?(body, with_one_child: true)
              check_source(:no_empty_lines, first_line, last_line)
            else
              check_source(:empty_lines, first_line, last_line)
            end
          else
            check_source(style, first_line, last_line)
          end
        end

        def check_source(style, start_line, end_line)
          case style
          when :no_empty_lines
            check_both(style, start_line, end_line, MSG_EXTRA, &:empty?)
          when :empty_lines
            check_both(style, start_line, end_line, MSG_MISSING) do |line|
              !line.empty?
            end
          end
        end

        def check_both(style, start_line, end_line, msg, &block)
          kind = self.class::KIND
          check_line(style, start_line, format(msg, kind, 'beginning'), &block)
          check_line(style, end_line - 2, format(msg, kind, 'end'), &block)
        end

        def check_line(style, line, msg)
          return unless yield(processed_source.lines[line])

          offset = style == :empty_lines && msg.include?('end.') ? 2 : 1
          range = source_range(processed_source.buffer, line + offset, 0)
          add_offense([style, range], range, msg)
        end

        def namespace?(node, with_one_child: true)
          if node.begin_type?
            return false if with_one_child
            node.children.all? { |child| constant_definition?(child) }
          else
            constant_definition?(node)
          end
        end
      end
    end
  end
end
