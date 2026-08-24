# frozen_string_literal: true

module RuboCop
  class CommentConfig
    # Handling of `push`/`pop` directives and their signed cop arguments:
    # saving and restoring the per-cop analysis state, and resolving the
    # `+`/`-` argument lists (shared with the `next` directive).
    # @api private
    module PushPop
      private

      def resolve_push_cops(directive)
        directive.push_args.transform_values do |names|
          names.flat_map { |name| expand_cop_name(name) }
        end
      end

      def expand_cop_name(name)
        registry = Cop::Registry.global
        cops = registry.department?(name) ? registry.names_for_department(name) : [name]
        cops.map { |c| qualified_cop_name(c) }
      end

      def apply_push(analyses, resolved_cops, directive)
        resolved_cops.each do |op, cops|
          cops.each { |cop| apply_cop_op(analyses, op, cop, directive) }
        end
      end

      def apply_cop_op(analyses, operation, cop, directive)
        analysis = analyses[cop]
        line = directive.line_number
        if operation == '-' && !analysis.start_line_number
          analyses[cop] = CopAnalysis.new(analysis.line_ranges, line, directive)
        elsif operation == '+' && analysis.start_line_number
          analyses[cop] = CopAnalysis.new(analysis.close(line), nil)
        end
      end

      def pop_state(analyses, line)
        restore_point = @stack.pop
        (restore_point.keys | analyses.keys).each do |cop|
          analyses[cop] = popped_analysis(analyses[cop], restore_point[cop], line)
        end
      end

      def popped_analysis(current, restored, line)
        ranges = current.close(line - 1)
        return CopAnalysis.new(ranges, nil) unless restored&.start_line_number

        CopAnalysis.new(ranges, line, restored.start_directive)
      end
    end
  end
end
