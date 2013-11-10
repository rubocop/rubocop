# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for parentheses in the definition of a method,
      # that does not take any arguments. Both instance and
      # class/singleton methods are checked.
      class DefWithParentheses < Cop
        include CheckMethods

        MSG = "Omit the parentheses in defs when the method doesn't accept " +
            'any arguments.'

        def check(node, _method_name, args, _body)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          convention(args, :begin) if args.children == [] && args.loc.begin
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end

      # This cop checks for missing parentheses in the definition of a
      # method, that takes arguments. Both instance and
      # class/singleton methods are checked.
      class DefWithoutParentheses < Cop
        include CheckMethods

        MSG = 'Use def with parentheses when there are arguments.'

        def check(_node, _method_name, args, _body)
          if args.children.size > 0 && args.loc.begin.nil?
            convention(args, :expression)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.insert_before(node.loc.expression, '(')
            corrector.insert_after(node.loc.expression, ')')
          end
        end
      end
    end
  end
end
