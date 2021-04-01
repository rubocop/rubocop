# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if/then/else/end constructs on a single line.
      # AlwaysCorrectToMultiline config option can be set to true to auto-convert all offenses to
      # multi-line constructs. When AlwaysCorrectToMultiline is false (default case) the
      # auto-correct will first try converting them to ternary operators.
      #
      # @example
      #   # bad
      #   if foo then bar else baz end
      #
      #   # bad
      #   unless foo then baz else bar end
      #
      #   # good
      #   foo ? bar : baz
      #
      #   # good
      #   bar if foo
      #
      #   # good
      #   if foo then bar end
      #
      #   # good
      #   if foo
      #     bar
      #   else
      #     baz
      #   end
      class OneLineConditional < Base
        include ConfigurableEnforcedStyle
        include OnNormalIfUnless
        extend AutoCorrector

        MSG = 'Favor the ternary operator (`?:`) or multi-line constructs ' \
              'over single-line `%<keyword>s/then/else/end` constructs.'

        def on_normal_if_unless(node)
          return unless node.single_line?
          return unless node.else_branch
          return if node.elsif?

          message = message(node)
          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement(node))
          end
        end

        private

        def message(node)
          format(MSG, keyword: node.keyword)
        end

        def replacement(node)
          if always_multiline? || cannot_replace_to_ternary?(node)
            multiline_replacement(node)
          else
            replaced_node = ternary_replacement(node)
            return replaced_node unless node.parent
            return "(#{replaced_node})" if %i[and or].include?(node.parent.type)
            return "(#{replaced_node})" if node.parent.send_type? && node.parent.operator_method?

            replaced_node
          end
        end

        def always_multiline?
          @config.for_cop('Style/OneLineConditional')['AlwaysCorrectToMultiline']
        end

        def cannot_replace_to_ternary?(node)
          node.elsif_conditional?
        end

        def multiline_replacement(node, indentation = nil)
          indentation = ' ' * node.source_range.column if indentation.nil?
          if_branch_source = node.if_branch&.source || 'nil'
          elsif_indentation = indentation if node.respond_to?(:elsif?) && node.elsif?
          if_branch = <<~RUBY
            #{elsif_indentation}#{node.keyword} #{node.condition.source}
            #{indentation}#{branch_body_indentation}#{if_branch_source}
          RUBY
          else_branch = else_branch_to_multiline(node.else_branch, indentation)
          if_branch + else_branch
        end

        def else_branch_to_multiline(else_branch, indentation)
          if else_branch.nil?
            'end'
          elsif else_branch.if_type? && else_branch.elsif?
            multiline_replacement(else_branch, indentation)
          else
            <<~RUBY.chomp
              #{indentation}else
              #{indentation}#{branch_body_indentation}#{else_branch.source}
              #{indentation}end
            RUBY
          end
        end

        def branch_body_indentation
          ' ' * (@config.for_cop('Layout/IndentationWidth')['Width'] || 2)
        end

        def ternary_replacement(node)
          condition, if_branch, else_branch = *node

          "#{expr_replacement(condition)} ? " \
            "#{expr_replacement(if_branch)} : " \
            "#{expr_replacement(else_branch)}"
        end

        def expr_replacement(node)
          return 'nil' if node.nil?

          requires_parentheses?(node) ? "(#{node.source})" : node.source
        end

        def requires_parentheses?(node)
          return true if %i[and or if].include?(node.type)
          return true if node.assignment?
          return true if method_call_with_changed_precedence?(node)

          keyword_with_changed_precedence?(node)
        end

        def method_call_with_changed_precedence?(node)
          return false unless node.send_type? && node.arguments?
          return false if node.parenthesized_call?

          !node.operator_method?
        end

        def keyword_with_changed_precedence?(node)
          return false unless node.keyword?
          return true if node.respond_to?(:prefix_not?) && node.prefix_not?

          node.respond_to?(:arguments?) && node.arguments? &&
            !node.parenthesized_call?
        end
      end
    end
  end
end
