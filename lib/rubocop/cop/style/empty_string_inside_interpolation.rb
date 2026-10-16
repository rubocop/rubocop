# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for empty strings being assigned inside string interpolation.
      #
      # Empty strings are a meaningless outcome inside of string interpolation, so we remove them.
      # Alternatively, when configured to do so, we prioritise using empty strings.
      #
      # While this cop would also apply to variables that are only going to be used as strings,
      # RuboCop can't detect that, so we only check inside of string interpolation.
      #
      # @example EnforcedStyle: trailing_conditional (default)
      #   # bad
      #   "#{condition ? 'foo' : ''}"
      #
      #   # good
      #   "#{'foo' if condition}"
      #
      #   # bad
      #   "#{condition ? '' : 'foo'}"
      #
      #   # good
      #   "#{'foo' unless condition}"
      #
      # @example EnforcedStyle: ternary
      #   # bad
      #   "#{'foo' if condition}"
      #
      #   # good
      #   "#{condition ? 'foo' : ''}"
      #
      #   # bad
      #   "#{'foo' unless condition}"
      #
      #   # good
      #   "#{condition ? '' : 'foo'}"
      #
      class EmptyStringInsideInterpolation < Base
        include ConfigurableEnforcedStyle
        include Interpolation
        extend AutoCorrector

        MSG_TRAILING_CONDITIONAL = 'Do not use trailing conditionals in string interpolation.'
        MSG_TERNARY = 'Do not return empty strings in string interpolation.'

        INTERPOLATED_TYPES = %i[dstr dsym regexp xstr].freeze

        def on_interpolation(node)
          node.each_child_node(:if) do |child_node|
            if style == :trailing_conditional
              trailing_conditional_correction(child_node)
            elsif style == :ternary
              ternary_correction(node, child_node)
            end
          end
        end

        private

        def trailing_conditional_correction(child_node)
          # A modifier `if`/`unless` is already a trailing conditional and has
          # no `else` branch, so the ternary-to-trailing rewrite does not apply.
          return if child_node.modifier_form?

          if empty_if_outcome?(child_node)
            ternary_style_autocorrect(child_node, child_node.else_branch, 'unless')
          end

          return unless empty_else_outcome?(child_node)

          ternary_style_autocorrect(child_node, child_node.if_branch, 'if')
        end

        def ternary_correction(node, child_node)
          return unless child_node.modifier_form?

          add_offense(node, message: MSG_TRAILING_CONDITIONAL) do |corrector|
            next if nested_trailing_conditional?(child_node)

            autocorrect_to_ternary(corrector, child_node)
          end
        end

        def nested_trailing_conditional?(if_node)
          if_node.each_descendant(:if).any? do |node|
            node.modifier_form? && node.parent.parent&.type?(*INTERPOLATED_TYPES)
          end
        end

        def autocorrect_to_ternary(corrector, if_node)
          condition = if_node.condition.source
          branch = ternary_branch_source(if_node.if_branch)
          outcomes = if_node.unless? ? "'' : #{branch}" : "#{branch} : ''"

          corrector.replace(if_node, "#{condition} ? #{outcomes}")
        end

        def ternary_branch_source(branch)
          return branch.source unless command_call?(branch)

          arguments = branch.first_argument.source_range.join(branch.last_argument.source_range)
          method = branch.source_range.begin.join(arguments.begin).source.rstrip

          "#{method}(#{arguments.source})"
        end

        def command_call?(node)
          return false unless node.type?(:call, :super, :yield) && node.arguments?
          return false if node.call_type? && (node.operator_method? || node.setter_method?)

          !node.parenthesized?
        end

        def empty_if_outcome?(node)
          empty_branch_outcome?(node.if_branch)
        end

        def empty_else_outcome?(node)
          empty_branch_outcome?(node.else_branch)
        end

        def empty_branch_outcome?(branch)
          return false unless branch

          branch.nil_type? || (branch.str_type? && branch.value.empty?)
        end

        def ternary_style_autocorrect(node, outcome, keyword)
          add_offense(node, message: MSG_TERNARY) do |corrector|
            next if empty_string_conditional_in_condition?(node)

            head = node.source_range.begin.join(outcome.source_range.begin)
            tail = outcome.source_range.end.join(node.source_range.end)

            corrector.remove(head)
            corrector.replace(tail, " #{keyword} #{node.condition.source}")
          end
        end

        def empty_string_conditional_in_condition?(if_node)
          if_node.condition.each_descendant(:if).any? do |node|
            next false if node.modifier_form? || !node.parent.parent&.type?(*INTERPOLATED_TYPES)

            empty_if_outcome?(node) || empty_else_outcome?(node)
          end
        end
      end
    end
  end
end
