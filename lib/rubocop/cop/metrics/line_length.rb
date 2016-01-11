# encoding: utf-8
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
            next unless line.length > max

            if allow_heredoc?
              next if line_in_whitelisted_heredoc?(heredocs, index.succ)
            end

            if allow_uri?
              uri_range = find_excessive_uri_range(line)
              next if uri_range && allowed_uri_position?(line, uri_range)
            end

            message = format(MSG, line.length, max)

            excessive_position = if uri_range && uri_range.begin < max
                                   uri_range.end
                                 else
                                   max
                                 end

            range = source_range(processed_source.buffer, index + 1,
                                 excessive_position...(line.length))

            add_offense(nil, range, message) { self.max = line.length }
          end
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

        def allow_uri?
          cop_config['AllowURI']
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
          @regexp ||= URI.regexp(cop_config['URISchemes'])
        end
      end
    end
  end
end
