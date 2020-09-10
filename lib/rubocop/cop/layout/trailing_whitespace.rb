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
      # @example AllowInHeredoc: false
      #   # The line in this example contains spaces after the 0.
      #   # bad
      #   code = <<~RUBY
      #     x = 0
      #   RUBY
      #
      #   # ok
      #   code = <<~RUBY
      #     x = 0 #{}
      #   RUBY
      #
      #   # good
      #   trailing_whitespace = ' '
      #   code = <<~RUBY
      #     x = 0#{trailing_whitespace}
      #   RUBY
      #
      # @example AllowInHeredoc: true (default)
      #   # The line in this example contains spaces after the 0.
      #   # good
      #   code = <<~RUBY
      #     x = 0
      #   RUBY
      #
      class TrailingWhitespace < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Trailing whitespace detected.'

        def on_new_investigation
          @heredoc_ranges = extract_heredoc_ranges(processed_source.ast)
          processed_source.lines.each_with_index do |line, index|
            next unless line.end_with?(' ', "\t")

            process_line(line, index + 1)
          end
        end

        private

        def process_line(line, lineno)
          in_heredoc = inside_heredoc?(lineno)
          return if skip_heredoc? && in_heredoc

          range = offense_range(lineno, line)
          add_offense(range) do |corrector|
            if in_heredoc
              corrector.insert_after(range, '#{}') # rubocop:disable Lint/InterpolationCheck
            else
              corrector.remove(range)
            end
          end
        end

        def skip_heredoc?
          cop_config.fetch('AllowInHeredoc', false)
        end

        def inside_heredoc?(line_number)
          @heredoc_ranges.any? { |r| r.include?(line_number) }
        end

        def extract_heredoc_ranges(ast)
          return [] unless ast

          ast.each_node(:str, :dstr, :xstr).select(&:heredoc?).map do |node|
            body = node.location.heredoc_body
            (body.first_line...body.last_line)
          end
        end

        def offense_range(lineno, line)
          source_range(processed_source.buffer, lineno, (line.rstrip.length)...(line.length))
        end
      end
    end
  end
end
