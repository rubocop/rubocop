# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This lint sees if there is a mismatch between the number of
      # expected fields for format/sprintf/#% and what is actually
      # passed as arguments.
      #
      # @example
      #
      #   # bad
      #
      #   format('A value: %s and another: %i', a_value)
      #
      # @example
      #
      #   # good
      #
      #   format('A value: %s and another: %i', a_value, another)
      class FormatParameterMismatch < Cop
        # http://rubular.com/r/CvpbxkcTzy
        MSG = "Number of arguments (%<arg_num>i) to `%<method>s` doesn't " \
              'match the number of fields (%<field_num>i).'
        FIELD_REGEX =
          /(%(([\s#+-0\*]*)(\d*)?(\.\d+)?[bBdiouxXeEfgGaAcps]|%))/.freeze
        NAMED_FIELD_REGEX = /%\{[_a-zA-Z][_a-zA-Z]+\}/.freeze
        KERNEL = 'Kernel'
        SHOVEL = '<<'
        PERCENT = '%'
        PERCENT_PERCENT = '%%'
        DIGIT_DOLLAR_FLAG = /%(\d+)\$/.freeze
        STRING_TYPES = %i[str dstr].freeze
        NAMED_INTERPOLATION = /%(?:<\w+>|\{\w+\})/.freeze

        def on_send(node)
          return unless offending_node?(node)

          add_offense(node, location: :selector)
        end

        private

        def offending_node?(node)
          return false unless called_on_string?(node)
          return false unless method_with_format_args?(node)
          return false if named_mode?(node) || splat_args?(node)

          num_of_format_args, num_of_expected_fields = count_matches(node)

          return false if num_of_format_args == :unknown

          matched_arguments_count?(num_of_expected_fields, num_of_format_args)
        end

        def matched_arguments_count?(expected, passed)
          if passed.negative?
            expected < passed.abs
          else
            expected != passed
          end
        end

        def_node_matcher :called_on_string?, <<-PATTERN
          {(send {nil? const_type?} _ (str _) ...)
           (send (str ...) ...)}
        PATTERN

        def method_with_format_args?(node)
          sprintf?(node) || format?(node) || percent?(node)
        end

        def named_mode?(node)
          relevant_node = if sprintf?(node) || format?(node)
                            node.first_argument
                          elsif percent?(node)
                            node.receiver
                          end

          !relevant_node.source.scan(NAMED_FIELD_REGEX).empty?
        end

        def splat_args?(node)
          return false if percent?(node)

          node.arguments.drop(1).any?(&:splat_type?)
        end

        def heredoc?(node)
          node.first_argument.source[0, 2] == SHOVEL
        end

        def count_matches(node)
          if countable_format?(node)
            count_format_matches(node)
          elsif countable_percent?(node)
            count_percent_matches(node)
          else
            [:unknown] * 2
          end
        end

        def countable_format?(node)
          (sprintf?(node) || format?(node)) && !heredoc?(node)
        end

        def countable_percent?(node)
          percent?(node) && node.first_argument.array_type?
        end

        def count_format_matches(node)
          [node.arguments.count - 1, expected_fields_count(node.first_argument)]
        end

        def count_percent_matches(node)
          [node.first_argument.child_nodes.count,
           expected_fields_count(node.receiver)]
        end

        def format_method?(name, node)
          return false if node.const_receiver? &&
                          !node.receiver.loc.name.is?(KERNEL)
          return false unless node.method?(name)

          node.arguments.size > 1 && node.first_argument.str_type?
        end

        def expected_fields_count(node)
          return :unknown unless node.str_type?
          return 1 if node.source =~ NAMED_INTERPOLATION

          max_digit_dollar_num = max_digit_dollar_num(node)
          return max_digit_dollar_num if max_digit_dollar_num&.nonzero?

          node
            .source
            .scan(FIELD_REGEX)
            .reject { |x| x.first == PERCENT_PERCENT }
            .reduce(0) { |acc, elem| acc + arguments_count(elem[2]) }
        end

        def max_digit_dollar_num(node)
          node.source.scan(DIGIT_DOLLAR_FLAG).map do |digit_dollar_num|
            digit_dollar_num.first.to_i
          end.max
        end

        # number of arguments required for the format sequence
        def arguments_count(format)
          format.scan('*').count + 1
        end

        def format?(node)
          format_method?(:format, node)
        end

        def sprintf?(node)
          format_method?(:sprintf, node)
        end

        def percent?(node)
          receiver = node.receiver

          percent = node.method?(:%) &&
                    (STRING_TYPES.include?(receiver.type) ||
                     node.first_argument.array_type?)

          return false if percent && STRING_TYPES.include?(receiver.type) &&
                          heredoc?(node)

          percent
        end

        def message(node)
          num_args_for_format, num_expected_fields = count_matches(node)

          method_name = node.method?(:%) ? 'String#%' : node.method_name

          format(MSG, arg_num: num_args_for_format, method: method_name,
                      field_num: num_expected_fields)
        end
      end
    end
  end
end
