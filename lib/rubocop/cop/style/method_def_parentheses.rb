# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks for parentheses around the arguments in method
      # definitions. Both instance and class/singleton methods are checked.
      class MethodDefParentheses < Cop
        include OnMethodDef
        include ConfigurableEnforcedStyle

        def on_method_def(node, _method_name, args, _body)
          if style == :require_parentheses
            if arguments?(args) && !parentheses?(args)
              missing_parentheses(node, args)
            else
              correct_style_detected
            end
          elsif parentheses?(args)
            unwanted_parentheses(args)
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if style == :require_parentheses
              args_expr = args_node(node).loc.expression
              args_with_space = range_with_surrounding_space(args_expr, :left)
              just_space = Parser::Source::Range.new(args_expr.source_buffer,
                                                     args_with_space.begin_pos,
                                                     args_expr.begin_pos)
              corrector.replace(just_space, '(')
              corrector.insert_after(args_expr, ')')
            elsif style == :require_no_parentheses
              corrector.replace(node.loc.begin, ' ')
              corrector.remove(node.loc.end)
            end
          end
        end

        private

        def missing_parentheses(node, args)
          add_offense(node, args.loc.expression,
                      'Use def with parentheses when there are parameters.') do
            opposite_style_detected
          end
        end

        def unwanted_parentheses(args)
          add_offense(args, :expression, 'Use def without parentheses.') do
            opposite_style_detected
          end
        end

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
