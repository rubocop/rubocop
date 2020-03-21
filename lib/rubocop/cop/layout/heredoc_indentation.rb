# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of the here document bodies. The bodies
      # are indented one step.
      # In Ruby 2.3 or newer, squiggly heredocs (`<<~`) should be used. If you
      # use the older rubies, you should introduce some library to your project
      # (e.g. ActiveSupport, Powerpack or Unindent).
      # Note: When `Layout/LineLength`'s `AllowHeredoc` is false (not default),
      #       this cop does not add any offenses for long here documents to
      #       avoid `Layout/LineLength`'s offenses.
      #
      # @example EnforcedStyle: squiggly (default)
      #   # bad
      #   <<-RUBY
      #   something
      #   RUBY
      #
      #   # good
      #   # When EnforcedStyle is squiggly, bad code is auto-corrected to the
      #   # following code.
      #   <<~RUBY
      #     something
      #   RUBY
      #
      # @example EnforcedStyle: active_support
      #   # good
      #   # When EnforcedStyle is active_support, bad code is auto-corrected to
      #   # the following code.
      #   <<-RUBY.strip_heredoc
      #     something
      #   RUBY
      #
      # @example EnforcedStyle: powerpack
      #   # good
      #   # When EnforcedStyle is powerpack, bad code is auto-corrected to
      #   # the following code.
      #   <<-RUBY.strip_indent
      #     something
      #   RUBY
      #
      # @example EnforcedStyle: unindent
      #   # good
      #   # When EnforcedStyle is unindent, bad code is auto-corrected to
      #   # the following code.
      #   <<-RUBY.unindent
      #     something
      #   RUBY
      #
      class HeredocIndentation < Cop
        include Heredoc
        include ConfigurableEnforcedStyle

        RUBY23_TYPE_MSG = 'Use %<indentation_width>d spaces for indentation ' \
                          'in a heredoc by using `<<~` instead of ' \
                          '`%<current_indent_type>s`.'
        RUBY23_WIDTH_MSG = 'Use %<indentation_width>d spaces for '\
                           'indentation in a heredoc.'
        LIBRARY_MSG = 'Use %<indentation_width>d spaces for indentation in a ' \
                      'heredoc by using %<method>s.'
        STRIP_METHODS = {
          unindent: 'unindent',
          active_support: 'strip_heredoc',
          powerpack: 'strip_indent'
        }.freeze

        def on_heredoc(node)
          body = heredoc_body(node)
          return if body.strip.empty?

          body_indent_level = indent_level(body)

          if heredoc_indent_type(node) == '~'
            expected_indent_level = base_indent_level(node) + indentation_width
            return if expected_indent_level == body_indent_level
          else
            return unless body_indent_level.zero?
          end

          return if line_too_long?(node)

          add_offense(node, location: :heredoc_body)
        end

        def autocorrect(node)
          check_style!

          case style
          when :squiggly
            correct_by_squiggly(node)
          else
            correct_by_library(node)
          end
        end

        private

        def message(node)
          case style
          when :squiggly
            current_indent_type = "<<#{heredoc_indent_type(node)}"
            ruby23_message(indentation_width, current_indent_type)
          when nil
            method = "some library(e.g. ActiveSupport's `String#strip_heredoc`)"
            library_message(indentation_width, method)
          else
            method = "`String##{STRIP_METHODS[style]}`"
            library_message(indentation_width, method)
          end
        end

        def library_message(indentation_width, method)
          format(
            LIBRARY_MSG,
            indentation_width: indentation_width,
            method: method
          )
        end

        def ruby23_message(indentation_width, current_indent_type)
          if current_indent_type == '<<~'
            ruby23_width_message(indentation_width)
          else
            ruby23_type_message(indentation_width, current_indent_type)
          end
        end

        def ruby23_type_message(indentation_width, current_indent_type)
          format(
            RUBY23_TYPE_MSG,
            indentation_width: indentation_width,
            current_indent_type: current_indent_type
          )
        end

        def ruby23_width_message(indentation_width)
          format(
            RUBY23_WIDTH_MSG,
            indentation_width: indentation_width
          )
        end

        def line_too_long?(node)
          return false if unlimited_heredoc_length?

          body = heredoc_body(node)

          expected_indent = base_indent_level(node) + indentation_width
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

        def max_line_length
          config.for_cop('Layout/LineLength')['Max']
        end

        def correct_by_squiggly(node)
          lambda do |corrector|
            if heredoc_indent_type(node) == '~'
              adjust_squiggly(corrector, node)
            else
              adjust_minus(corrector, node)
            end
          end
        end

        def adjust_squiggly(corrector, node)
          corrector.replace(node.loc.heredoc_body, indented_body(node))
          corrector.replace(node.loc.heredoc_end, indented_end(node))
        end

        def adjust_minus(corrector, node)
          heredoc_beginning = node.loc.expression.source
          corrected = heredoc_beginning.sub(/<<-?/, '<<~')
          corrector.replace(node.loc.expression, corrected)
        end

        def correct_by_library(node)
          lambda do |corrector|
            corrector.replace(node.loc.heredoc_body, indented_body(node))
            corrected = ".#{STRIP_METHODS[style]}"
            corrector.insert_after(node.loc.expression, corrected)
          end
        end

        def check_style!
          return if style

          raise Warning, "Auto-correction does not work for #{cop_name}. " \
                         'Please configure EnforcedStyle.'
        end

        def indented_body(node)
          body = heredoc_body(node)
          body_indent_level = indent_level(body)
          correct_indent_level = base_indent_level(node) + indentation_width
          body.gsub(/^[^\S\r\n]{#{body_indent_level}}/,
                    ' ' * correct_indent_level)
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
          base_line_num = node.loc.expression.line
          base_line = processed_source.lines[base_line_num - 1]
          indent_level(base_line)
        end

        def indent_level(str)
          indentations = str.lines
                            .map { |line| line[/^\s*/] }
                            .reject { |line| line == "\n" }
          indentations.empty? ? 0 : indentations.min_by(&:size).size
        end

        # Returns '~', '-' or nil
        def heredoc_indent_type(node)
          node.source[/^<<([~-])/, 1]
        end

        def indentation_width
          @config.for_cop('Layout/IndentationWidth')['Width'] || 2
        end

        def heredoc_body(node)
          node.loc.heredoc_body.source.scrub
        end

        def heredoc_end(node)
          node.loc.heredoc_end.source.scrub
        end
      end
    end
  end
end
