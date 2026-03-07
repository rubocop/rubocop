# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks the indentation of the here document bodies. The bodies
      # are indented one step.
      #
      # NOTE: When ``Layout/LineLength``'s `AllowHeredoc` is false (not default),
      #       this cop does not add any offenses for long here documents to
      #       avoid ``Layout/LineLength``'s offenses.
      #
      # @example
      #   # bad
      #   <<~RUBY
      #   something
      #   RUBY
      #
      #   # good
      #   <<~RUBY
      #     something
      #   RUBY
      #
      class HeredocIndentation < Base
        include Alignment
        include Heredoc
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Use %<indentation_width>d spaces for indentation in a heredoc.'

        def on_heredoc(node)
          body = heredoc_body(node)
          return if body.strip.empty?

          return unless squiggly_heredoc?(node)

          body_indent_level = indent_level(body)
          expected_indent_level = base_indent_level(node) + configured_indentation_width
          return if expected_indent_level == body_indent_level

          return if line_too_long?(node)

          register_offense(node)
        end

        private

        def register_offense(node)
          message = format(MSG, indentation_width: configured_indentation_width)
          add_offense(node.loc.heredoc_body, message: message) do |corrector|
            corrector.replace(node.loc.heredoc_body, indented_body(node))
            corrector.replace(node.loc.heredoc_end, indented_end(node))
          end
        end

        def line_too_long?(node)
          return false unless max_line_length
          return false if unlimited_heredoc_length?

          body = heredoc_body(node)

          expected_indent = base_indent_level(node) + configured_indentation_width
          actual_indent = indent_level(body)
          increase_indent_level = expected_indent - actual_indent

          longest_line(body).size + increase_indent_level >= max_line_length
        end

        def longest_line(lines)
          lines.each_line.max_by { |line| line.chomp.size }.chomp
        end

        def unlimited_heredoc_length?
          config.for_cop('Layout/LineLength')['AllowHeredoc']
        end

        def indented_body(node)
          body = heredoc_body(node)
          body_indent_level = indent_level(body)
          correct_indent_level = base_indent_level(node) + configured_indentation_width
          body.gsub(/^[^\S\r\n]{#{body_indent_level}}/, ' ' * correct_indent_level)
        end

        def indented_end(node)
          end_ = heredoc_end(node)
          end_indent_level = indent_level(end_)
          correct_indent_level = base_indent_level(node)
          if end_indent_level < correct_indent_level
            end_.gsub(/^\s{#{end_indent_level}}/, ' ' * correct_indent_level)
          else
            end_
          end
        end

        def base_indent_level(node)
          base_line_num = node.source_range.line
          base_line = processed_source.lines[base_line_num - 1]
          indent_level(base_line)
        end

        def heredoc_end(node)
          node.loc.heredoc_end.source
        end
      end
    end
  end
end
