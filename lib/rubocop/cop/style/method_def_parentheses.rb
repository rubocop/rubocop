# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for parentheses around the arguments in method
      # definitions. Both instance and class/singleton methods are checked.
      #
      # @example EnforcedStyle: require_parentheses (default)
      #   # The `require_parentheses` style requires method definitions
      #   # to always use parentheses
      #
      #   # bad
      #   def bar num1, num2
      #     num1 + num2
      #   end
      #
      #   def foo descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name
      #     do_something
      #   end
      #
      #   # good
      #   def bar(num1, num2)
      #     num1 + num2
      #   end
      #
      #   def foo(descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name)
      #     do_something
      #   end
      #
      # @example EnforcedStyle: require_no_parentheses
      #   # The `require_no_parentheses` style requires method definitions
      #   # to never use parentheses
      #
      #   # bad
      #   def bar(num1, num2)
      #     num1 + num2
      #   end
      #
      #   def foo(descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name)
      #     do_something
      #   end
      #
      #   # good
      #   def bar num1, num2
      #     num1 + num2
      #   end
      #
      #   def foo descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name
      #     do_something
      #   end
      #
      # @example EnforcedStyle: require_no_parentheses_except_multiline
      #   # The `require_no_parentheses_except_multiline` style prefers no
      #   # parentheses when method definition arguments fit on single line,
      #   # but prefers parentheses when arguments span multiple lines.
      #
      #   # bad
      #   def bar(num1, num2)
      #     num1 + num2
      #   end
      #
      #   def foo descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name
      #     do_something
      #   end
      #
      #   # good
      #   def bar num1, num2
      #     num1 + num2
      #   end
      #
      #   def foo(descriptive_var_name,
      #           another_descriptive_var_name,
      #           last_descriptive_var_name)
      #     do_something
      #   end
      class MethodDefParentheses < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        MSG_PRESENT = 'Use def without parentheses.'
        MSG_MISSING = 'Use def with parentheses when there are ' \
                      'parameters.'

        def on_def(node)
          args = node.arguments

          if require_parentheses?(args)
            if arguments_without_parentheses?(node)
              missing_parentheses(node)
            else
              correct_style_detected
            end
          elsif parentheses?(args)
            unwanted_parentheses(args)
          else
            correct_style_detected
          end
        end
        alias on_defs on_def

        private

        def correct_arguments(arg_node, corrector)
          corrector.replace(arg_node.loc.begin, ' ')
          corrector.remove(arg_node.loc.end)
        end

        def correct_definition(def_node, corrector)
          arguments_range = def_node.arguments.source_range
          args_with_space = range_with_surrounding_space(range: arguments_range,
                                                         side: :left)
          leading_space = range_between(args_with_space.begin_pos,
                                        arguments_range.begin_pos)
          corrector.replace(leading_space, '(')
          corrector.insert_after(arguments_range, ')')
        end

        def require_parentheses?(args)
          style == :require_parentheses ||
            (style == :require_no_parentheses_except_multiline &&
             args.multiline?)
        end

        def arguments_without_parentheses?(node)
          node.arguments? && !parentheses?(node.arguments)
        end

        def missing_parentheses(node)
          location = node.arguments.source_range

          add_offense(location, message: MSG_MISSING) do |corrector|
            correct_definition(node, corrector)
          end
        end

        def unwanted_parentheses(args)
          add_offense(args, message: MSG_PRESENT) do |corrector|
            # offense is registered on args node when parentheses are unwanted
            correct_arguments(args, corrector)
          end
        end
      end
    end
  end
end
