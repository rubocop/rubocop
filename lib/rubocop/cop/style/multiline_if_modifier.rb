# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if/unless modifiers with multiple-lines bodies.
      #
      # @example
      #
      #   # bad
      #   {
      #     result: 'this should not happen'
      #   } unless cond
      #
      #   # good
      #   { result: 'ok' } if cond
      class MultilineIfModifier < Base
        include StatementModifier
        include Alignment
        include RangeHelp
        extend AutoCorrector

        MSG = 'Favor a normal %<keyword>s-statement over a modifier ' \
              'clause in a multiline statement.'

        def on_if(node)
          return if part_of_ignored_node?(node)
          return unless node.modifier_form? && node.body.multiline?

          add_offense(node, message: format(MSG, keyword: node.keyword)) do |corrector|
            autocorrect(corrector, node)
          end
          ignore_node(node)
        end

        private

        def autocorrect(corrector, node)
          condition_heredoc, body_heredoc = [node.condition, node.body].map do |part|
            next unless (range = heredoc_after(part, node))

            corrector.remove(range)
            range.source.chomp
          end
          corrector.replace(node, to_normal_if(node, condition_heredoc, body_heredoc))
        end

        # Heredocs opened on the modifier line have their bodies after it, so
        # they are moved along with the part of the `if` they belong to.
        def heredoc_after(part, node)
          ranges = part.each_node(:any_str).select(&:heredoc?).map do |heredoc|
            heredoc.loc.heredoc_body.join(heredoc.loc.heredoc_end)
          end
          ranges.select! { |range| range.line > node.last_line }
          return if ranges.empty?

          range_by_whole_lines(ranges.reduce(:join), include_final_newline: true)
        end

        def to_normal_if(node, condition_heredoc, body_heredoc)
          indented_body = indented_body(node.body, node)
          condition = "#{node.keyword} #{node.condition.source}"
          indented_end = "#{offset(node)}end"

          lines = [condition, condition_heredoc, indented_body, body_heredoc, indented_end]
          lines.compact.join("\n")
        end

        def indented_body(body, node)
          body_source = "#{offset(node)}#{body.source}"
          verbatim_lines = verbatim_lines_in(body)
          body_source.each_line.with_index(body.first_line).map do |line, line_number|
            if line == "\n" || verbatim_lines.include?(line_number)
              line
            else
              line.sub(/^\s{#{offset(node).length}}/, indentation(node))
            end
          end.join
        end

        def verbatim_lines_in(body)
          body.each_node(:any_str).filter_map { |str| verbatim_line_range(str) }.flat_map(&:to_a)
        end

        # The indentation of a line that starts inside a string is part of the
        # string. Only squiggly heredocs strip it from their bodies, and a `<<`
        # terminator has to stay at the start of its line.
        def verbatim_line_range(str)
          if str.heredoc?
            str.loc.heredoc_body.line..str.loc.heredoc_end.line unless str.source.start_with?('<<~')
          elsif str.loc?(:begin) && str.loc?(:end)
            (str.first_line + 1)..str.last_line
          end
        end
      end
    end
  end
end
