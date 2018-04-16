# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop looks for trailing whitespace in the source code.
      #
      # @example
      #   # The line in this example contains spaces after the 0.
      #   # bad
      #   x = 0
      #
      #   # The line in this example ends directly after the 0.
      #   # good
      #   x = 0
      #
      class TrailingWhitespace < Cop
        include RangeHelp

        MSG = 'Trailing whitespace detected.'.freeze

        def investigate(processed_source)
          heredoc_ranges = extract_heredoc_ranges(processed_source.ast)
          processed_source.lines.each_with_index do |line, index|
            next unless line.end_with?(' ', "\t")
            next if skip_heredoc? && inside_heredoc?(heredoc_ranges, index + 1)

            range = source_range(processed_source.buffer,
                                 index + 1,
                                 (line.rstrip.length)...(line.length))

            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        def skip_heredoc?
          cop_config.fetch('AllowInHeredoc', false)
        end

        def inside_heredoc?(heredoc_ranges, line_number)
          heredoc_ranges.any? { |r| r.include?(line_number) }
        end

        def extract_heredoc_ranges(ast)
          return [] unless ast
          ast.each_node(:str, :dstr, :xstr).select(&:heredoc?).map do |node|
            body = node.location.heredoc_body
            (body.first_line...body.last_line)
          end
        end
      end
    end
  end
end
