# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for parentheses around the arguments in method
      # definitions. Both instance and class/singleton methods are checked.
      class MethodDefParentheses < Cop
        include CheckMethods

        def check(_node, _method_name, args, _body)
          if style == :require_parentheses &&
              has_arguments?(args) &&
              !has_parentheses?(args)
            add_offence(args,
                        :expression,
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
              corrector.insert_before(node.loc.expression, '(')
              corrector.insert_after(node.loc.expression, ')')
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

        def style
          case cop_config['EnforcedStyle']
          when 'require_parentheses' then :require_parentheses
          when 'require_no_parentheses' then :require_no_parentheses
          else fail 'Unknown style selected!'
          end
        end
      end
    end
  end
end
