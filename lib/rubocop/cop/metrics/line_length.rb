# frozen_string_literal: true

require 'uri'

module RuboCop
  module Cop
    module Metrics
      # This cop checks the length of lines in the source code.
      # The maximum length is configurable.
      class LineLength < Cop
        include ConfigurableMax

        MSG = 'Line is too long. [%d/%d]'.freeze

        def investigate(processed_source)
          heredocs = extract_heredocs(processed_source.ast) if allow_heredoc?
          processed_source.lines.each_with_index do |line, index|
            check_line(line, index, heredocs)
          end
        end

        private

        def check_line(line, index, heredocs)
          return if line.length <= max
          return if matches_ignored_pattern?(line)
          if ignore_cop_directives? && directive_on_source_line?(index)
            return check_directive_line(line, index)
          end
          return if heredocs &&
                    line_in_whitelisted_heredoc?(heredocs, index.succ)
          return check_uri_line(line, index) if allow_uri?

          offense(
            source_range(processed_source.buffer, index + 1, 0...line.length),
            line
          )
        end

        def offense(loc, line)
          message = format(MSG, line.length, max)
          add_offense(nil, loc, message) { self.max = line.length }
        end

        def excess_range(uri_range, line, index)
          excessive_position = if uri_range && uri_range.begin < max
                                 uri_range.end
                               else
                                 max
                               end

          source_range(processed_source.buffer, index + 1,
                       excessive_position...(line.length))
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
          ast.each_node.with_object([]) do |node, heredocs|
            next unless node.location.is_a?(Parser::Source::Map::Heredoc)
            body = node.location.heredoc_body
            delimiter = node.location.heredoc_end.source.strip
            heredocs << [body.first_line...body.last_line, delimiter]
          end
        end

        def line_in_whitelisted_heredoc?(heredocs, line_number)
          heredocs.any? do |range, delimiter|
            range.cover?(line_number) &&
              (allowed_heredoc == true || allowed_heredoc.include?(delimiter))
          end
        end

        def matches_ignored_pattern?(line)
          ignored_patterns.any? { |pattern| Regexp.new(pattern).match(line) }
        end

        def ignored_patterns
          cop_config['IgnoredPatterns'] || []
        end

        def allow_uri?
          cop_config['AllowURI']
        end

        def ignore_cop_directives?
          cop_config['IgnoreCopDirectives']
        end

        def allowed_uri_position?(line, uri_range)
          uri_range.begin < max && uri_range.end == line.length
        end

        def find_excessive_uri_range(line)
          last_uri_match = match_uris(line).last
          return nil unless last_uri_match
          begin_position, end_position = last_uri_match.offset(0)
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
        rescue
          false
        end

        def uri_regexp
          @regexp ||= URI::Parser.new.make_regexp(cop_config['URISchemes'])
        end

        def check_directive_line(line, index)
          return if line_length_without_directive(line) <= max

          range = max..(line_length_without_directive(line) - 1)
          offense(source_range(processed_source.buffer, index + 1, range), line)
        end

        def directive_on_source_line?(index)
          source_line_number = index + processed_source.buffer.first_line
          comment =
            processed_source
            .comments
            .detect { |e| e.location.line == source_line_number }

          return false unless comment
          comment.text.match(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
        end

        def line_length_without_directive(line)
          before_comment, = line.split('#')
          before_comment.rstrip.length
        end

        def check_uri_line(line, index)
          uri_range = find_excessive_uri_range(line)
          return if uri_range && allowed_uri_position?(line, uri_range)

          offense(excess_range(uri_range, line, index), line)
        end
      end
    end
  end
end
