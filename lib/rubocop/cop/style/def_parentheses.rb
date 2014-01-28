# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for parentheses in the definition of a method,
      # that does not take any arguments. Both instance and
      # class/singleton methods are checked.
      class DefWithParentheses < Cop
        include CheckMethods

        MSG = "Omit the parentheses in defs when the method doesn't accept " \
            'any arguments.'

        def check(node, _method_name, args, _body)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          add_offence(args, :begin) if args.children == [] && args.loc.begin
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
