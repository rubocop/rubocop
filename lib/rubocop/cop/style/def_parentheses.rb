# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for parentheses in the definition of a method,
      # that does not take any arguments. Both instance and
      # class/singleton methods are checked.
      class DefWithParentheses < Cop
        MSG = "Omit the parentheses in defs when the method doesn't accept " +
            'any arguments.'

        def on_def(node)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          _, args = *node
          if args.children == [] && args.loc.begin
            add_offence(:convention, args.loc.begin, MSG)
          end
        end

        def on_defs(node)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          _, _, args = *node
          if args.children == [] && args.loc.begin
            add_offence(:convention, args.loc.begin, MSG)
          end
        end
      end

      # This cop checks for missing parentheses in the definition of a
      # method, that takes arguments. Both instance and
      # class/singleton methods are checked.
      class DefWithoutParentheses < Cop
        MSG = 'Use def with parentheses when there are arguments.'

        def on_def(node)
          _, args = *node

          if args.children.size > 0 && args.loc.begin.nil?
            add_offence(:convention, args.loc.expression, MSG)
          end
        end

        def on_defs(node)
          _, _, args = *node

          if args.children.size > 0 && args.loc.begin.nil?
            add_offence(:convention, args.loc.expression, MSG)
          end
        end
      end
    end
  end
end
