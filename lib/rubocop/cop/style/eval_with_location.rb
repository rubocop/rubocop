# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop ensures that eval methods (`eval`, `instance_eval`, `class_eval`
      # and `module_eval`) are given filename and line number values (`__FILE__`
      # and `__LINE__`). This data is used to ensure that any errors raised
      # within the evaluated code will be given the correct identification
      # in a backtrace.
      #
      # The cop also checks that the line number given relative to `__LINE__` is
      # correct.
      #
      # @example
      #   # bad
      #   eval <<-RUBY
      #     def do_something
      #     end
      #   RUBY
      #
      #   # bad
      #   C.class_eval <<-RUBY
      #     def do_something
      #     end
      #   RUBY
      #
      #   # good
      #   eval <<-RUBY, binding, __FILE__, __LINE__ + 1
      #     def do_something
      #     end
      #   RUBY
      #
      #   # good
      #   C.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      #     def do_something
      #     end
      #   RUBY
      class EvalWithLocation < Base
        MSG = 'Pass `__FILE__` and `__LINE__` to `%<method_name>s`.'
        MSG_EVAL = 'Pass a binding, `__FILE__` and `__LINE__` to `eval`.'
        MSG_INCORRECT_LINE = 'Incorrect line number for `%<method_name>s`; ' \
                             'use `%<expected>s` instead of `%<actual>s`.'

        RESTRICT_ON_SEND = %i[eval class_eval module_eval instance_eval].freeze

        def_node_matcher :eval_without_location?, <<~PATTERN
          {
            (send nil? :eval ${str dstr})
            (send nil? :eval ${str dstr} _)
            (send nil? :eval ${str dstr} _ #special_file_keyword?)
            (send nil? :eval ${str dstr} _ #special_file_keyword? _)

            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr})
            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr} #special_file_keyword?)
            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr} #special_file_keyword? _)
          }
        PATTERN

        def_node_matcher :line_with_offset?, <<~PATTERN
          {
            (send #special_line_keyword? %1 (int %2))
            (send (int %2) %1 #special_line_keyword?)
          }
        PATTERN

        def on_send(node)
          eval_without_location?(node) do |code|
            if with_lineno?(node)
              on_with_lineno(node, code)
            else
              msg = node.method?(:eval) ? MSG_EVAL : format(MSG, method_name: node.method_name)
              add_offense(node, message: msg)
            end
          end
        end

        private

        def special_file_keyword?(node)
          node.str_type? &&
            node.source == '__FILE__'
        end

        def special_line_keyword?(node)
          node.int_type? &&
            node.source == '__LINE__'
        end

        # FIXME: It's a Style/ConditionalAssignment's false positive.
        # rubocop:disable Style/ConditionalAssignment
        def with_lineno?(node)
          if node.method?(:eval)
            node.arguments.size == 4
          else
            node.arguments.size == 3
          end
        end
        # rubocop:enable Style/ConditionalAssignment

        def message_incorrect_line(method_name, actual, sign, line_diff)
          expected =
            if line_diff.zero?
              '__LINE__'
            else
              "__LINE__ #{sign} #{line_diff}"
            end

          format(MSG_INCORRECT_LINE,
                 method_name: method_name,
                 actual: actual.source,
                 expected: expected)
        end

        def on_with_lineno(node, code)
          line_node = node.arguments.last
          lineno_range = line_node.loc.expression
          line_diff = string_first_line(code) - lineno_range.first_line
          if line_diff.zero?
            add_offense_for_same_line(node, line_node)
          else
            add_offense_for_different_line(node, line_node, line_diff)
          end
        end

        def string_first_line(str_node)
          if str_node.heredoc?
            str_node.loc.heredoc_body.first_line
          else
            str_node.loc.expression.first_line
          end
        end

        def add_offense_for_same_line(node, line_node)
          return if special_line_keyword?(line_node)

          add_offense(
            line_node.loc.expression,
            message: message_incorrect_line(node.method_name, line_node, nil, 0)
          )
        end

        def add_offense_for_different_line(node, line_node, line_diff)
          sign = line_diff.positive? ? :+ : :-
          return if line_with_offset?(line_node, sign, line_diff.abs)

          add_offense(
            line_node.loc.expression,
            message: message_incorrect_line(node.method_name, line_node, sign, line_diff.abs)
          )
        end
      end
    end
  end
end
