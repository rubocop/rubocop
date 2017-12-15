# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for if and unless statements that would fit on one line
      # if written as a modifier if/unless. The maximum line length is
      # configured in the `Metrics/LineLength` cop.
      #
      # @example
      #   # bad
      #   if condition
      #     do_stuff(bar)
      #   end
      #
      #   unless qux.empty?
      #     Foo.do_something
      #   end
      #
      #   # good
      #   do_stuff(bar) if condition
      #   Foo.do_something unless qux.empty?
      class IfUnlessModifier < Cop
        include StatementModifier

        MSG = 'Favor modifier `%<keyword>s` usage when having a single-line ' \
              'body. Another good alternative is the usage of control flow ' \
              '`&&`/`||`.'.freeze

        ASSIGNMENT_TYPES = %i[lvasgn casgn cvasgn
                              gvasgn ivasgn masgn].freeze

        def on_if(node)
          return unless eligible_node?(node)

          add_offense(node, location: :keyword,
                            message: format(MSG, keyword: node.keyword))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, to_modifier_form(node))
          end
        end

        private

        def eligible_node?(node)
          !non_eligible_if?(node) && !node.chained? &&
            !node.nested_conditional? && single_line_as_modifier?(node)
        end

        def non_eligible_if?(node)
          node.ternary? || node.modifier_form? || node.elsif? || node.else?
        end

        def parenthesize?(node)
          # Parenthesize corrected expression if changing to modifier-if form
          # would change the meaning of the parent expression
          # (due to the low operator precedence of modifier-if)
          return false if node.parent.nil?
          return true if ASSIGNMENT_TYPES.include?(node.parent.type)

          if node.parent.send_type?
            _receiver, _name, *args = *node.parent
            return !method_uses_parens?(node.parent, args.first)
          end

          false
        end

        def method_uses_parens?(node, limit)
          source = node.source_range.source_line[0...limit.loc.column]
          source =~ /\s*\(\s*$/
        end

        def to_modifier_form(node)
          expression = [node.body.source,
                        node.keyword,
                        node.condition.source,
                        first_line_comment(node)].compact.join(' ')

          parenthesize?(node) ? "(#{expression})" : expression
        end

        def first_line_comment(node)
          comment =
            processed_source.comments.find { |c| c.loc.line == node.loc.line }

          comment ? comment.loc.expression.source : nil
        end
      end
    end
  end
end
