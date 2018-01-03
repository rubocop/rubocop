# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comments put on the same line as some keywords.
      # These keywords are: `begin`, `class`, `def`, `end`, `module`.
      #
      # Note that some comments (such as `:nodoc:` and `rubocop:disable`) are
      # allowed.
      #
      # @example
      #   # bad
      #   if condition
      #     statement
      #   end # end if
      #
      #   # bad
      #   class X # comment
      #     statement
      #   end
      #
      #   # bad
      #   def x; end # comment
      #
      #   # good
      #   if condition
      #     statement
      #   end
      #
      #   # good
      #   class X # :nodoc:
      #     y
      #   end
      class CommentedKeyword < Cop
        include RangeHelp

        MSG = 'Do not place comments on the same line as the ' \
              '`%<keyword>s` keyword.'.freeze

        def investigate(processed_source)
          heredoc_lines = extract_heredoc_lines(processed_source.ast)

          processed_source.each_comment do |comment|
            location = comment.location
            line_position = location.line
            line = processed_source.lines[line_position - 1]
            next if heredoc_lines.any? { |r| r.include?(line_position) }
            next unless offensive?(line)
            range = source_range(processed_source.buffer,
                                 line_position,
                                 (location.column)...(location.last_column))

            add_offense(range, location: range)
          end
        end

        private

        KEYWORDS = %w[begin class def end module].freeze
        ALLOWED_COMMENTS = %w[:nodoc: rubocop:disable].freeze

        def offensive?(line)
          line = line.lstrip
          KEYWORDS.any? { |word| line =~ /^#{word}\s/ } &&
            ALLOWED_COMMENTS.none? { |c| line =~ /#\s*#{c}/ }
        end

        def message(node)
          line = node.source_line
          keyword = /^\s*(\S+).*#/.match(line)[1]
          format(MSG, keyword: keyword)
        end

        def extract_heredoc_lines(ast)
          return [] unless ast
          ast.each_node.with_object([]) do |node, heredocs|
            next unless node.location.is_a?(Parser::Source::Map::Heredoc)
            body = node.location.heredoc_body
            heredocs << (body.first_line...body.last_line)
          end
        end
      end
    end
  end
end
