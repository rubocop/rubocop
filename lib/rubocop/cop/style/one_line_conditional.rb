# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # TODO: Make configurable.
      # Checks for uses of if/then/else/end on a single line.
      #
      # @example
      #   # bad
      #   if foo then boo else doo end
      #   unless foo then boo else goo end
      #
      #   # good
      #   foo ? boo : doo
      #   boo if foo
      #   if foo then boo end
      #
      #   # good
      #   if foo
      #     boo
      #   else
      #     doo
      #   end
      class OneLineConditional < Cop
        include OnNormalIfUnless

        MSG_USE_TERNARY = 'Favor the ternary operator (`?:`) ' \
                          'over `%<keyword>s/then/else/end` constructs.'
        MSG_USE_MULTILINE = 'Use multiple lines for ' \
                            '`if/then/elsif/then/else/end` constructs.'

        def on_normal_if_unless(node)
          return unless node.single_line? && node.else_branch && !node.elsif?

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        private

        def message(node)
          if node.elsif_conditional?
            MSG_USE_MULTILINE
          else
            format(MSG_USE_TERNARY, keyword: node.keyword)
          end
        end

        def replacement(node)
          return to_ternary_or_multiline(node) unless node.parent

          if %i[and or].include?(node.parent.type)
            return "(#{to_ternary_or_multiline(node)})"
          end

          if node.parent.send_type? && node.parent.operator_method?
            return "(#{to_ternary_or_multiline(node)})"
          end

          to_ternary_or_multiline(node)
        end

        def to_ternary_or_multiline(node)
          node.elsif_conditional? ? to_multiline(node) : to_ternary(node)
        end

        def to_multiline(node)
          indentation = ' ' * node.source_range.column
          to_indented_multiline(node, indentation)
        end

        def to_indented_multiline(node, indentation)
          if_branch = <<~RUBY
            #{node.keyword} #{node.condition.source}
            #{indentation}  #{node.if_branch.source}
          RUBY
          else_branch = else_branch_to_multiline(node.else_branch, indentation)
          if_branch + else_branch
        end

        def else_branch_to_multiline(else_branch, indentation)
          if else_branch.if_type? && else_branch.elsif?
            to_indented_multiline(else_branch, indentation)
          else
            <<~RUBY.chomp
              #{indentation}else
              #{indentation}  #{else_branch.source}
              #{indentation}end
            RUBY
          end
        end

        def to_ternary(node)
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
          return true if node.prefix_not?

          node.arguments? && !node.parenthesized_call?
        end
      end
    end
  end
end
