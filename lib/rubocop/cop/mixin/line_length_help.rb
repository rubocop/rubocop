# frozen_string_literal: true

module RuboCop
  module Cop
    # Help methods for determining if a line is too long.
    module LineLengthHelp
      private

      def ignore_cop_directives?
        config.for_cop('Layout/LineLength')['IgnoreCopDirectives']
      end

      def directive_on_source_line?(line_index)
        source_line_number = line_index + processed_source.buffer.first_line
        comment =
          processed_source.comments
                          .detect { |e| e.location.line == source_line_number }

        return false unless comment

        comment.text.match?(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
      end

      def allow_uri?
        config.for_cop('Layout/LineLength')['AllowURI']
      end

      def allowed_uri_position?(line, uri_range)
        uri_range.begin < max_line_length &&
          (uri_range.end == line_length(line) ||
           uri_range.end == line_length(line) - 1)
      end

      def line_length(line)
        line.length + indentation_difference(line)
      end

      def find_excessive_uri_range(line)
        last_uri_match = match_uris(line).last
        return nil unless last_uri_match

        begin_position, end_position = last_uri_match.offset(0).map do |pos|
          pos + indentation_difference(line)
        end
        return nil if begin_position < max_line_length &&
                      end_position < max_line_length

        begin_position...end_position
      end

      def match_uris(string)
        matches = []
        string.scan(uri_regexp) do
          matches << $LAST_MATCH_INFO if valid_uri?($LAST_MATCH_INFO[0])
        end
        matches
      end

      def indentation_difference(line)
        return 0 unless tab_indentation_width

        line.match(/^\t*/)[0].size * (tab_indentation_width - 1)
      end

      def tab_indentation_width
        config.for_cop('Layout/IndentationStyle')['IndentationWidth'] ||
          config.for_cop('Layout/IndentationWidth')['Width']
      end

      def uri_regexp
        @uri_regexp ||=
          URI::DEFAULT_PARSER
          .make_regexp(config.for_cop('Layout/LineLength')['URISchemes'])
      end

      def valid_uri?(uri_ish_string)
        URI.parse(uri_ish_string)
        true
      rescue URI::InvalidURIError, NoMethodError
        false
      end

      def line_length_without_directive(line)
        before_comment, = line.split(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
        before_comment.rstrip.length
      end
    end
  end
end
