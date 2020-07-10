# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unnecessary conditional expressions.
      #
      # @example
      #   # bad
      #   a = b ? b : c
      #
      #   # good
      #   a = b || c
      #
      # @example
      #   # bad
      #   if b
      #     b
      #   else
      #     c
      #   end
      #
      #   # good
      #   b || c
      #
      #   # good
      #   if b
      #     b
      #   elsif cond
      #     c
      #   end
      #
      class RedundantCondition < Cop
        include RangeHelp

        MSG = 'Use double pipes `||` instead.'
        REDUNDANT_CONDITION = 'This condition is not needed.'

        def on_if(node)
          return if node.elsif_conditional?
          return unless offense?(node)

          add_offense(node, location: range_of_offense(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            if node.ternary?
              correct_ternary(corrector, node)
            elsif node.modifier_form? || !node.else_branch
              corrector.replace(node, node.if_branch.source)
            else
              corrected = make_ternary_form(node)

              corrector.replace(node, corrected)
            end
          end
        end

        private

        def message(node)
          if node.modifier_form? || !node.else_branch
            REDUNDANT_CONDITION
          else
            MSG
          end
        end

        def range_of_offense(node)
          return :expression unless node.ternary?

          range_between(node.loc.question.begin_pos, node.loc.colon.end_pos)
        end

        def offense?(node)
          condition, if_branch, else_branch = *node

          return false if use_if_branch?(else_branch)

          condition == if_branch && !node.elsif? && (
            node.ternary? ||
            !else_branch.instance_of?(AST::Node) ||
            else_branch.single_line?
          )
        end

        def use_if_branch?(else_branch)
          else_branch&.if_type?
        end

        def else_source(else_branch)
          if require_parentheses?(else_branch)
            "(#{else_branch.source})"
          elsif without_argument_parentheses_method?(else_branch)
            "#{else_branch.method_name}(#{else_branch.arguments.map(&:source).join(', ')})"
          else
            else_branch.source
          end
        end

        def make_ternary_form(node)
          _condition, if_branch, else_branch = *node
          ternary_form = [if_branch.source,
                          else_source(else_branch)].join(' || ')

          if node.parent&.send_type?
            "(#{ternary_form})"
          else
            ternary_form
          end
        end

        def correct_ternary(corrector, node)
          corrector.replace(range_of_offense(node), '||')

          return unless node.else_branch.range_type?

          corrector.wrap(node.else_branch, '(', ')')
        end

        def require_parentheses?(node)
          node.basic_conditional? &&
            node.modifier_form? ||
            node.range_type? ||
            node.rescue_type? ||
            node.respond_to?(:semantic_operator?) && node.semantic_operator?
        end

        def without_argument_parentheses_method?(node)
          node.send_type? && !node.arguments.empty? && !node.parenthesized?
        end
      end
    end
  end
end
