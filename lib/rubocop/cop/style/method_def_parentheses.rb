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
          if style == :require_parentheses
            if arguments?(args) && !parentheses?(args)
              add_offence(node,
                          args.loc.expression,
                          'Use def with parentheses when there are ' \
                          'parameters.') do
                opposite_style_detected
              end
            else
              correct_style_detected
            end
          elsif parentheses?(args)
            add_offence(args, :expression, 'Use def without parentheses.') do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if style == :require_parentheses

              corrector.insert_after(args_node(node).loc.expression, ')')
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

        def args_node(def_node)
          if def_node.type == :def
            _method_name, args, _body = *def_node
            args
          else
            _scope, _method_name, args, _body = *def_node
            args
          end
        end

        def arguments?(args)
          args.children.size > 0
        end

        def parentheses?(args)
          args.loc.begin
        end
      end
    end
  end
end
