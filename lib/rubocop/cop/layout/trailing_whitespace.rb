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
      # @example AllowInHeredoc: false (default)
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
      # @example AllowInHeredoc: true
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
          @heredocs = extract_heredocs(processed_source.ast)
          processed_source.lines.each_with_index do |line, index|
            next unless line.end_with?(' ', "\t")

            process_line(line, index + 1)
          end
        end

        private

        def process_line(line, lineno)
          heredoc = find_heredoc(lineno)
          return if skip_heredoc? && heredoc

          range = offense_range(lineno, line)
          add_offense(range) do |corrector|
            if heredoc
              corrector.wrap(range, "\#{'", "'}") unless static?(heredoc)
            else
              corrector.remove(range)
            end
          end
        end

        def static?(heredoc)
          heredoc.loc.expression.source.end_with? "'"
        end

        def skip_heredoc?
          cop_config.fetch('AllowInHeredoc', false)
        end

        def find_heredoc(line_number)
          @heredocs.each { |node, r| return node if r.include?(line_number) }
          nil
        end

        def extract_heredocs(ast)
          return [] unless ast

          ast.each_node(:str, :dstr, :xstr).select(&:heredoc?).map do |node|
            body = node.location.heredoc_body
            [node, body.first_line...body.last_line]
          end
        end

        def offense_range(lineno, line)
          source_range(processed_source.buffer, lineno, (line.rstrip.length)...(line.length))
        end
      end
    end
  end
end
