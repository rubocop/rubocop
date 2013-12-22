# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for parentheses around the arguments in method
      # definitions. Both instance and class/singleton methods are checked.
      class MethodDefParentheses < Cop
        include CheckMethods
        include ConfigurableEnforcedStyle

        def check(node, _method_name, args, _body)
          if style == :require_parentheses &&
              has_arguments?(args) &&
              !has_parentheses?(args)
            add_offence(node,
                        args.loc.expression,
                        'Use def with parentheses when there are parameters.')
          elsif style == :require_no_parentheses && has_parentheses?(args)
            add_offence(args,
                        :expression,
                        'Use def without parentheses.')
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if style == :require_parentheses
              corrector.insert_after(node.children[1].loc.expression, ')')
              expression = node.loc.expression
              replacement = expression.source.sub(/(def\s+\S+)\s+/, '\1(')
              corrector.replace(expression, replacement)
            elsif style == :require_no_parentheses
              corrector.replace(node.loc.begin, ' ')
              corrector.remove(node.loc.end)
            end
          end
        end

        private

        def has_arguments?(args)
          args.children.size > 0
        end

        def has_parentheses?(args)
          args.loc.begin
        end
      end
    end
  end
end
