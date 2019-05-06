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
      class UnneededCondition < Cop
        include RangeHelp

        MSG = 'Use double pipes `||` instead.'
        UNNEEDED_CONDITION = 'This condition is not needed.'

        def on_if(node)
          return if node.elsif_conditional?
          return unless offense?(node)

          add_offense(node, location: range_of_offense(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            if node.ternary?
              corrector.replace(range_of_offense(node), '||')
            elsif node.modifier_form? || !node.else_branch
              corrector.replace(node.source_range, node.if_branch.source)
            else
              corrected = make_ternary_form(node)

              corrector.replace(node.source_range, corrected)
            end
          end
        end

        private

        def message(node)
          if node.modifier_form? || !node.else_branch
            UNNEEDED_CONDITION
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
          wrap_else =
            else_branch.basic_conditional? && else_branch.modifier_form?
          wrap_else ? "(#{else_branch.source})" : else_branch.source
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
      end
    end
  end
end
