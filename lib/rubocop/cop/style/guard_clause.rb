# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use a guard clause instead of wrapping the code inside a conditional
      # expression
      #
      # A condition with an `elsif` or `else` branch is allowed unless
      # one of `return`, `break`, `next`, `raise`, or `fail` is used
      # in the body of the conditional expression.
      #
      # NOTE: Autocorrect works in most cases except with if-else statements
      #   that contain logical operators such as `foo || raise('exception')`
      #
      # @example
      #   # bad
      #   def test
      #     if something
      #       work
      #     end
      #   end
      #
      #   # good
      #   def test
      #     return unless something
      #
      #     work
      #   end
      #
      #   # also good
      #   def test
      #     work if something
      #   end
      #
      #   # bad
      #   if something
      #     raise 'exception'
      #   else
      #     ok
      #   end
      #
      #   # good
      #   raise 'exception' if something
      #   ok
      #
      #   # bad
      #   if something
      #     foo || raise('exception')
      #   else
      #     ok
      #   end
      #
      #   # good
      #   foo || raise('exception') if something
      #   ok
      #
      # @example AllowConsecutiveConditionals: false (default)
      #   # bad
      #   def test
      #     if foo?
      #       work
      #     end
      #
      #     if bar?  # <- reports an offense
      #       work
      #     end
      #   end
      #
      # @example AllowConsecutiveConditionals: true
      #   # good
      #   def test
      #     if foo?
      #       work
      #     end
      #
      #     if bar?
      #       work
      #     end
      #   end
      #
      #   # bad
      #   def test
      #     if foo?
      #       work
      #     end
      #
      #     do_something
      #
      #     if bar?  # <- reports an offense
      #       work
      #     end
      #   end
      #
      class GuardClause < Base
        extend AutoCorrector
        include MinBodyLength
        include StatementModifier

        MSG = 'Use a guard clause (`%<example>s`) instead of wrapping the ' \
              'code inside a conditional expression.'

        def on_def(node)
          body = node.body

          return unless body

          check_ending_body(body)
        end
        alias on_defs on_def

        def on_if(node)
          return if accepted_form?(node)

          if (guard_clause = node.if_branch&.guard_clause?)
            kw = node.loc.keyword.source
            guard = :if
          elsif (guard_clause = node.else_branch&.guard_clause?)
            kw = node.inverse_keyword
            guard = :else
          else
            return
          end

          guard = nil if and_or_guard_clause?(guard_clause)

          register_offense(node, guard_clause_source(guard_clause), kw, guard)
        end

        private

        def check_ending_body(body)
          return if body.nil?

          if body.if_type?
            check_ending_if(body)
          elsif body.begin_type?
            final_expression = body.children.last
            check_ending_if(final_expression) if final_expression&.if_type?
          end
        end

        def check_ending_if(node)
          return if accepted_form?(node, ending: true) || !min_body_length?(node)
          return if allowed_consecutive_conditionals? &&
                    consecutive_conditionals?(node.parent, node)

          register_offense(node, 'return', node.inverse_keyword)

          check_ending_body(node.if_branch)
        end

        def consecutive_conditionals?(parent, node)
          parent.each_child_node.inject(false) do |if_type, child|
            break if_type if node == child

            child.if_type?
          end
        end

        def register_offense(node, scope_exiting_keyword, conditional_keyword, guard = nil)
          condition, = node.node_parts
          example = [scope_exiting_keyword, conditional_keyword, condition.source].join(' ')
          if too_long_for_single_line?(node, example)
            return if trivial?(node)

            example = "#{conditional_keyword} #{condition.source}; #{scope_exiting_keyword}; end"
            replacement = <<~RUBY.chomp
              #{conditional_keyword} #{condition.source}
                #{scope_exiting_keyword}
              end
            RUBY
          end

          add_offense(node.loc.keyword, message: format(MSG, example: example)) do |corrector|
            next if node.else? && guard.nil?

            autocorrect(corrector, node, condition, replacement || example, guard)
          end
        end

        def autocorrect(corrector, node, condition, replacement, guard)
          corrector.replace(node.loc.keyword.join(condition.loc.expression), replacement)
          corrector.remove(node.loc.end)
          return unless node.else?

          corrector.remove(node.loc.else)
          corrector.remove(branch_to_remove(node, guard))
        end

        def branch_to_remove(node, guard)
          case guard
          when :if then node.if_branch
          when :else then node.else_branch
          end
        end

        def guard_clause_source(guard_clause)
          if and_or_guard_clause?(guard_clause)
            guard_clause.parent.source
          else
            guard_clause.source
          end
        end

        def and_or_guard_clause?(guard_clause)
          parent = guard_clause.parent
          parent.and_type? || parent.or_type?
        end

        def too_long_for_single_line?(node, example)
          max = max_line_length
          max && node.source_range.column + example.length > max
        end

        def accepted_form?(node, ending: false)
          accepted_if?(node, ending) || node.condition.multiline? || node.parent&.assignment?
        end

        def trivial?(node)
          node.branches.one? && !node.if_branch.if_type? && !node.if_branch.begin_type?
        end

        def accepted_if?(node, ending)
          return true if node.modifier_form? || node.ternary?

          if ending
            node.else?
          else
            !node.else? || node.elsif?
          end
        end

        def allowed_consecutive_conditionals?
          cop_config.fetch('AllowConsecutiveConditionals', false)
        end
      end
    end
  end
end
