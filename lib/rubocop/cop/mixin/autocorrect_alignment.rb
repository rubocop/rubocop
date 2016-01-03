# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # This module does auto-correction of nodes that should just be moved to
    # the left or to the right, amount being determined by the instance
    # variable @column_delta.
    module AutocorrectAlignment
      SPACE = ' '.freeze

      def configured_indentation_width
        cop_config['IndentationWidth'] ||
          config.for_cop('IndentationWidth')['Width']
      end

      def indentation(node)
        offset(node) + (SPACE * configured_indentation_width)
      end

      def offset(node)
        SPACE * node.loc.column
      end

      def check_alignment(items, base_column = nil)
        base_column ||= items.first.loc.column unless items.empty?
        prev_line = -1
        items.each do |current|
          if current.loc.line > prev_line &&
             begins_its_line?(current.source_range)
            @column_delta = base_column - current.loc.column
            if @column_delta != 0
              expr = current.source_range
              if offenses.any? { |o| within?(expr, o.location) }
                # If this offense is within a line range that is already being
                # realigned by autocorrect, we report the offense without
                # autocorrecting it. Two rewrites in the same area by the same
                # cop can not be handled. The next iteration will find the
                # offense again and correct it.
                add_offense(nil, expr)
              else
                add_offense(current, :expression)
              end
            end
          end
          prev_line = current.loc.line
        end
      end

      def autocorrect(arg)
        return unless arg

        heredoc_ranges = heredoc_ranges(arg)
        expr = arg.respond_to?(:loc) ? arg.loc.expression : arg

        # We can't use the instance variable inside the lambda. That would just
        # give each lambda the same reference and they would all get the last
        # value of @column_delta. A local variable fixes the problem.
        column_delta = @column_delta

        return if block_comment_within?(expr)

        lambda do |corrector|
          each_line(expr) do |line_begin_pos|
            autocorrect_line(corrector, line_begin_pos, expr, column_delta,
                             heredoc_ranges)
          end
        end
      end

      private

      def autocorrect_line(corrector, line_begin_pos, expr, column_delta,
                           heredoc_ranges)
        range = calculate_range(expr, line_begin_pos, column_delta)
        # We must not change indentation of heredoc strings.
        return if heredoc_ranges.any? { |h| within?(range, h) }

        if column_delta > 0
          unless range.source == "\n"
            corrector.insert_before(range, ' ' * column_delta)
          end
        elsif range.source =~ /\A[ \t]+\z/
          remove(range, corrector)
        end
      end

      def heredoc_ranges(arg)
        return [] unless arg.is_a?(Parser::AST::Node)

        arg.each_node(:dstr)
           .select { |n| n.loc.respond_to?(:heredoc_body) }
           .map { |n| n.loc.heredoc_body.join(n.loc.heredoc_end) }
      end

      def block_comment_within?(expr)
        processed_source.comments.select(&:document?).any? do |c|
          within?(c.loc.expression, expr)
        end
      end

      def within?(inner, outer)
        inner.begin_pos >= outer.begin_pos && inner.end_pos <= outer.end_pos
      end

      def calculate_range(expr, line_begin_pos, column_delta)
        starts_with_space = expr.source_buffer.source[line_begin_pos] =~ / /
        pos_to_remove = if column_delta > 0 || starts_with_space
                          line_begin_pos
                        else
                          line_begin_pos - column_delta.abs
                        end
        Parser::Source::Range.new(expr.source_buffer, pos_to_remove,
                                  pos_to_remove + column_delta.abs)
      end

      def remove(range, corrector)
        original_stderr = $stderr
        $stderr = StringIO.new # Avoid error messages on console
        corrector.remove(range)
      rescue RuntimeError
        range = Parser::Source::Range.new(range.source_buffer,
                                          range.begin_pos + 1,
                                          range.end_pos + 1)
        retry if range.source =~ /^ +$/
      ensure
        $stderr = original_stderr
      end

      def each_line(expr)
        line_begin_pos = expr.begin_pos
        expr.source.each_line do |line|
          yield line_begin_pos
          line_begin_pos += line.length
        end
      end
    end
  end
end
