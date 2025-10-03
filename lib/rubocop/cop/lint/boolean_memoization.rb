# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for boolean memoization using `||=` operator.
      #
      # The `||=` operator will re-execute the right-hand side if a falsy value
      # is assigned, which means memoization won't work properly for boolean values.
      # Use `defined?`-based memoization instead.
      #
      # @safety
      #   Autocorrection is unsafe for this cop because code may intentionally
      #   expect multiple calls when the value is falsy.
      #
      # @example
      #   # bad
      #   def foo
      #     @foo ||= do_something?
      #   end
      #
      #   # bad
      #   def foo
      #     @foo ||= do_something == 42
      #   end
      #
      #   # bad
      #   def foo
      #     @foo ||= !do_something
      #   end
      #
      #   # good
      #   def foo
      #     return @foo if defined?(@foo)
      #     @foo ||= do_something?
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= do_something
      #   end
      #
      class BooleanMemoization < Base
        extend AutoCorrector

        MSG = 'Use `defined?`-based memoization instead.'

        def on_or_asgn(node)
          lhs = node.lhs
          return unless lhs.ivasgn_type?

          method_node = node.each_ancestor(:any_def).first
          return if method_node&.body != node
          return unless boolean_result?(node.rhs)

          add_offense(node) do |corrector|
            autocorrect(corrector, method_node, lhs.source, node.rhs.source)
          end
        end

        private

        def boolean_result?(node)
          if node.any_block_type?
            boolean_result?(node.send_node)
          elsif node.send_type?
            node.predicate_method? || node.comparison_method? || node.negation_method?
          end
        end

        def autocorrect(corrector, node, variable_name, rhs_source)
          corrector.replace(node.body, <<~RUBY.rstrip)
            return #{variable_name} if defined?(#{variable_name})
            #{variable_name} = #{rhs_source}
          RUBY
          return unless node.endless?

          range = node.loc.assignment.join(node.body.source_range.begin)

          corrector.replace(range, "\n")
          corrector.insert_after(node, "\nend")
        end
      end
    end
  end
end
