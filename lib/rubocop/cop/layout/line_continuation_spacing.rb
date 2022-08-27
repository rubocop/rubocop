# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that the backslash of a line continuation is separated from
      # preceding text by exactly one space (default) or zero spaces.
      #
      # @example EnforcedStyle: space (default)
      #   # bad
      #   'a'\
      #   'b'  \
      #   'c'
      #
      #   # good
      #   'a' \
      #   'b' \
      #   'c'
      #
      # @example EnforcedStyle: no_space
      #   # bad
      #   'a' \
      #   'b'  \
      #   'c'
      #
      #   # good
      #   'a'\
      #   'b'\
      #   'c'
      class LineContinuationSpacing < Base
        include RangeHelp
        extend AutoCorrector

        def on_new_investigation
          last_line = last_line(processed_source)

          @ignored_ranges = string_literal_ranges(processed_source.ast) +
                            comment_ranges(processed_source.comments)

          processed_source.raw_source.lines.each_with_index do |line, index|
            break if index >= last_line

            line_number = index + 1
            investigate(line, line_number)
          end
        end

        private

        def investigate(line, line_number)
          offensive_spacing = find_offensive_spacing(line)
          return unless offensive_spacing

          range = source_range(
            processed_source.buffer,
            line_number,
            line.length - offensive_spacing.length - 1,
            offensive_spacing.length
          )

          return if ignore_range?(range)

          add_offense(range) { |corrector| autocorrect(corrector, range) }
        end

        def find_offensive_spacing(line)
          if no_space_style?
            line[/\s+\\$/, 0]
          elsif space_style?
            line[/((?<!\s)|\s{2,})\\$/, 0]
          end
        end

        def message(_range)
          if no_space_style?
            'Use zero spaces in front of backslash.'
          elsif space_style?
            'Use one space in front of backslash.'
          end
        end

        def autocorrect(corrector, range)
          correction = if no_space_style?
                         '\\'
                       elsif space_style?
                         ' \\'
                       end
          corrector.replace(range, correction)
        end

        def string_literal_ranges(ast)
          # which lines start inside a string literal?
          return [] if ast.nil?

          ast.each_node(:str, :dstr).each_with_object(Set.new) do |str, ranges|
            loc = str.location

            if str.heredoc?
              ranges << loc.heredoc_body
            elsif loc.respond_to?(:begin) && loc.begin
              ranges << loc.expression
            end
          end
        end

        def comment_ranges(comments)
          comments.map(&:loc).map(&:expression)
        end

        def last_line(processed_source)
          last_token = processed_source.tokens.last

          last_token ? last_token.line : processed_source.lines.length
        end

        def ignore_range?(backtick_range)
          @ignored_ranges.any? { |range| range.contains?(backtick_range) }
        end

        def no_space_style?
          cop_config['EnforcedStyle'] == 'no_space'
        end

        def space_style?
          cop_config['EnforcedStyle'] == 'space'
        end
      end
    end
  end
end
