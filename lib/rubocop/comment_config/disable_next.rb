# frozen_string_literal: true

module RuboCop
  class CommentConfig
    # Handling of `disable-next` directives: computing the statement scope
    # they apply to and tracking directives that attached to nothing.
    # The scope is the whole statement starting on the next line bearing
    # code. Comment-only lines between the directive and the code chain (so
    # several directives can stack), while a blank line breaks the attachment.
    # @api private
    module DisableNext
      # `disable-next` directives that suppress nothing: nothing follows
      # them, or they sit at the end of a code line.
      def detached_next_directives
        cop_disabled_line_ranges # ensure the analysis that collects them ran
        @detached_next_directives
      end

      # The line range of the statement a `disable-next` directive on the
      # given line scopes to (or would scope to), or `nil` when no statement
      # is attached. A directive is only honored on a comment-only line.
      # Stacked directives share the target, so the computation is memoized.
      # @api private
      def statement_scope_after(line)
        return nil unless comment_only_line?(line)

        code_line = attached_code_line(line)
        return nil unless code_line

        (@statement_bounds ||= {})[code_line] ||= statement_bounds_at(code_line)
      end

      private

      def apply_disable_next(analyses, directive)
        bounds = statement_scope_after(directive.line_number)
        return @detached_next_directives << directive unless bounds

        range = DirectiveRange.new(bounds.begin, bounds.end, directive)
        directive.cop_names.each do |cop_name|
          add_next_range(analyses, qualified_cop_name(cop_name), range)
        end
      end

      def add_next_range(analyses, cop_name, range)
        analysis = analyses[cop_name]
        analyses[cop_name] = CopAnalysis.new(analysis.line_ranges + [range],
                                             analysis.start_line_number, analysis.start_directive)
      end

      def attached_code_line(directive_line)
        ((directive_line + 1)..processed_source.lines.size).each do |line|
          return line unless comment_only_line?(line)
          return nil if processed_source[line - 1].blank?
        end

        nil
      end

      def statement_bounds_at(line)
        statement = statement_starting_at(line)
        # A code line where no statement starts (e.g. a lone `end`) scopes
        # the directive to that line alone.
        return (line..line) unless statement

        (line..statement_end_line(statement))
      end

      def statement_start_line?(node, line)
        # Synthetic nodes (e.g. parentheses-less argument lists) have no
        # source range. `begin` nodes are sequences of statements, not
        # statements themselves - taking one would scope the directive to
        # everything up to the last statement of the sequence.
        node.source_range && node.first_line == line && !node.begin_type?
      end

      def statement_starting_at(line)
        ast = processed_source.ast
        return nil unless ast

        ast.each_node.select { |node| statement_start_line?(node, line) }.max_by(&:last_line)
      end

      def statement_end_line(statement)
        statement.each_node.filter_map do |node|
          next unless node.source_range

          heredoc?(node) ? node.loc.heredoc_end.line : node.last_line
        end.max
      end

      def heredoc?(node)
        node.respond_to?(:heredoc?) && node.heredoc?
      end
    end
  end
end
