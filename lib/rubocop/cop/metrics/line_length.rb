# frozen_string_literal: true

require 'uri'

# rubocop:disable Metrics/ClassLength
module RuboCop
  module Cop
    module Metrics
      # This cop checks the length of lines in the source code.
      # The maximum length is configurable.
      # The tab size is configured in the `IndentationWidth`
      # of the `Layout/Tab` cop.
      # It also ignores a shebang line by default.
      #
      # This cop has some autocorrection capabilities.
      # It can programmatically shorten certain long lines by
      # inserting line breaks into expressions that can be safely
      # split across lines. These include arrays, hashes, and
      # method calls with argument lists.
      #
      # If autocorrection is enabled, the following Layout cops
      # are recommended to further format the broken lines.
      #
      #   - AlignArray
      #   - AlignHash
      #   - AlignParameters
      #   - ClosingParenthesisIndentation
      #   - IndentFirstArgument
      #   - IndentFirstArrayElement
      #   - IndentFirstHashElement
      #   - IndentFirstParameter
      #   - MultilineArrayLineBreaks
      #   - MultilineHashBraceLayout
      #   - MultilineHashKeyLineBreaks
      #   - MultilineMethodArgumentLineBreaks
      #
      # Together, these cops will pretty print hashes, arrays,
      # method calls, etc. For example, let's say the max columns
      # is 25:
      #
      # @example
      #
      #   # bad
      #   {foo: "0000000000", bar: "0000000000", baz: "0000000000"}
      #
      #   # good
      #   {foo: "0000000000",
      #   bar: "0000000000", baz: "0000000000"}
      #
      #   # good (with recommended cops enabled)
      #   {
      #     foo: "0000000000",
      #     bar: "0000000000",
      #     baz: "0000000000",
      #   }
      class LineLength < Cop
        include CheckLineBreakable
        include ConfigurableMax
        include IgnoredPattern
        include RangeHelp

        MSG = 'Line is too long. [%<length>d/%<max>d]'

        def on_potential_breakable_node(node)
          check_for_breakable_node(node)
        end
        alias on_array on_potential_breakable_node
        alias on_hash on_potential_breakable_node
        alias on_send on_potential_breakable_node

        def investigate_post_walk(processed_source)
          processed_source.lines.each_with_index do |line, line_index|
            check_line(line, line_index)
          end
        end

        def autocorrect(range)
          return if range.nil?

          lambda do |corrector|
            corrector.insert_before(range, "\n")
          end
        end

        private

        def check_for_breakable_node(node)
          breakable_node = extract_breakable_node(node, max)
          return if breakable_node.nil?

          line_index = breakable_node.first_line - 1
          breakable_nodes_by_line_index[line_index] = breakable_node
        end

        def breakable_nodes_by_line_index
          @breakable_nodes_by_line_index ||= {}
        end

        def heredocs
          @heredocs ||= extract_heredocs(processed_source.ast)
        end

        def tab_indentation_width
          config.for_cop('Layout/Tab')['IndentationWidth']
        end

        def indentation_difference(line)
          return 0 unless tab_indentation_width

          line.match(/^\t*/)[0].size * (tab_indentation_width - 1)
        end

        def line_length(line)
          line.length + indentation_difference(line)
        end

        def highlight_start(line)
          max - indentation_difference(line)
        end

        def check_line(line, line_index)
          return if line_length(line) <= max
          return if ignored_line?(line, line_index)

          if ignore_cop_directives? && directive_on_source_line?(line_index)
            return check_directive_line(line, line_index)
          end
          return check_uri_line(line, line_index) if allow_uri?

          register_offense(
            excess_range(nil, line, line_index),
            line,
            line_index
          )
        end

        def ignored_line?(line, line_index)
          matches_ignored_pattern?(line) ||
            shebang?(line, line_index) ||
            heredocs && line_in_permitted_heredoc?(line_index.succ)
        end

        def shebang?(line, line_index)
          line_index.zero? && line.start_with?('#!')
        end

        def register_offense(loc, line, line_index)
          message = format(MSG, length: line_length(line), max: max)

          breakable_range = breakable_range(line, line_index)
          add_offense(breakable_range, location: loc, message: message) do
            self.max = line_length(line)
          end
        end

        def breakable_range(line, line_index)
          return if line_in_heredoc?(line_index + 1)

          semicolon_range = breakable_semicolon_range(line, line_index)
          return semicolon_range if semicolon_range

          breakable_node = breakable_nodes_by_line_index[line_index]
          return breakable_node.source_range if breakable_node
        end

        def breakable_semicolon_range(line, line_index)
          semicolon_separated_parts = line.split(';')
          return if semicolon_separated_parts.length <= 1

          column = semicolon_separated_parts.first.length + 1
          range = source_range(processed_source.buffer, line_index, column, 1)
          return if processed_source.commented?(range)

          range
        end

        def excess_range(uri_range, line, line_index)
          excessive_position = if uri_range && uri_range.begin < max
                                 uri_range.end
                               else
                                 highlight_start(line)
                               end

          source_range(processed_source.buffer, line_index + 1,
                       excessive_position...(line_length(line)))
        end

        def max
          cop_config['Max']
        end

        def allow_heredoc?
          allowed_heredoc
        end

        def allowed_heredoc
          cop_config['AllowHeredoc']
        end

        def extract_heredocs(ast)
          return [] unless ast

          ast.each_node(:str, :dstr, :xstr).select(&:heredoc?).map do |node|
            body = node.location.heredoc_body
            delimiter = node.location.heredoc_end.source.strip
            [body.first_line...body.last_line, delimiter]
          end
        end

        def line_in_permitted_heredoc?(line_number)
          return false unless allowed_heredoc

          heredocs.any? do |range, delimiter|
            range.cover?(line_number) &&
              (allowed_heredoc == true || allowed_heredoc.include?(delimiter))
          end
        end

        def line_in_heredoc?(line_number)
          heredocs.any? do |range, _delimiter|
            range.cover?(line_number)
          end
        end

        def allow_uri?
          cop_config['AllowURI']
        end

        def ignore_cop_directives?
          cop_config['IgnoreCopDirectives']
        end

        def allowed_uri_position?(line, uri_range)
          uri_range.begin < max &&
            (uri_range.end == line_length(line) ||
             uri_range.end == line_length(line) - 1)
        end

        def find_excessive_uri_range(line)
          last_uri_match = match_uris(line).last
          return nil unless last_uri_match

          begin_position, end_position =
            last_uri_match.offset(0).map do |pos|
              pos + indentation_difference(line)
            end
          return nil if begin_position < max && end_position < max

          begin_position...end_position
        end

        def match_uris(string)
          matches = []
          string.scan(uri_regexp) do
            matches << $LAST_MATCH_INFO if valid_uri?($LAST_MATCH_INFO[0])
          end
          matches
        end

        def valid_uri?(uri_ish_string)
          URI.parse(uri_ish_string)
          true
        rescue URI::InvalidURIError, NoMethodError
          false
        end

        def uri_regexp
          @uri_regexp ||=
            URI::DEFAULT_PARSER.make_regexp(cop_config['URISchemes'])
        end

        def check_directive_line(line, line_index)
          return if line_length_without_directive(line) <= max

          range = max..(line_length_without_directive(line) - 1)
          register_offense(
            source_range(
              processed_source.buffer,
              line_index + 1,
              range
            ),
            line,
            line_index
          )
        end

        def directive_on_source_line?(line_index)
          source_line_number = line_index + processed_source.buffer.first_line
          comment =
            processed_source
            .comments
            .detect { |e| e.location.line == source_line_number }

          return false unless comment

          comment.text.match(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
        end

        def line_length_without_directive(line)
          before_comment, = line.split(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
          before_comment.rstrip.length
        end

        def check_uri_line(line, line_index)
          uri_range = find_excessive_uri_range(line)
          return if uri_range && allowed_uri_position?(line, uri_range)

          register_offense(
            excess_range(uri_range, line, line_index),
            line,
            line_index
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
