# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for parentheses around the arguments in method
      # definitions. Both instance and class/singleton methods are checked.
      class MethodDefParentheses < Cop
        include OnMethodDef
        include ConfigurableEnforcedStyle

        def on_method_def(node, _method_name, args, _body)
          if require_parentheses?(args)
            if arguments_without_parentheses?(args)
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
            if node.args_type?
              # offense is registered on args node when parentheses are unwanted
              corrector.replace(node.loc.begin, ' ')
              corrector.remove(node.loc.end)
            else
              args_expr = args_node(node).source_range
              args_with_space = range_with_surrounding_space(args_expr, :left)
              just_space = Parser::Source::Range.new(args_expr.source_buffer,
                                                     args_with_space.begin_pos,
                                                     args_expr.begin_pos)
              corrector.replace(just_space, '(')
              corrector.insert_after(args_expr, ')')
            end
          end
        end

        private

        def require_parentheses?(args)
          style == :require_parentheses ||
            (style == :require_no_parentheses_except_multiline &&
             args.multiline?)
        end

        def arguments_without_parentheses?(args)
          arguments?(args) && !parentheses?(args)
        end

        def missing_parentheses(node, args)
          add_offense(node, args.source_range,
                      'Use def with parentheses when there are parameters.') do
            unexpected_style_detected(:require_no_parentheses)
          end
        end

        def unwanted_parentheses(args)
          add_offense(args, :expression, 'Use def without parentheses.') do
            unexpected_style_detected(:require_parentheses)
          end
        end

        def args_node(def_node)
          if def_node.def_type?
            _method_name, args, _body = *def_node
          else
            _scope, _method_name, args, _body = *def_node
          end
          args
        end

        def arguments?(args)
          !args.children.empty?
        end
      end
    end
  end
end
