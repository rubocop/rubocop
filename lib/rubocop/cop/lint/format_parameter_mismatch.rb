# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This lint sees if there is a mismatch between the number of
      # expected fields for format/sprintf/#% and what is actually
      # passed as arguments.
      #
      # @example
      #
      #   format('A value: %s and another: %i', a_value)
      #
      class FormatParameterMismatch < Cop
        # http://rubular.com/r/HdWs2uXZv4
        MSG = 'Number arguments (%i) to `%s` mismatches expected fields (%i).'
        FIELDS_REGEX = /%([\s#+-0\*])?([0-9]*)?(.[0-9]+)?[bBdiouxXeEfgGacps]/

        def fields_regex
          FIELDS_REGEX
        end

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        private

        def offending_node?(node)
          if sprintf?(node) || format?(node) || percent?(node)
            num_of_args_for_format, num_of_expected_fields = count_matches(node)
            num_of_expected_fields != num_of_args_for_format
          else
            false
          end
        end

        def count_matches(node)
          receiver_node, _method_name, *args = *node

          if sprintf?(node) || format?(node)
            number_of_args_for_format = (args.size - 1)
            number_of_expected_fields = expected_fields(args.first).size
          elsif percent?(node)
            number_of_args_for_format = args.first.child_nodes.size
            number_of_expected_fields = expected_fields(receiver_node).size
          end

          [number_of_args_for_format, number_of_expected_fields]
        end

        def format_method?(name, node)
          receiver, method_name, *args = *node

          # commands have no explicit receiver
          return false unless !receiver && method_name == name

          args.size > 1 && :str == args.first.type
        end

        def expected_fields(node)
          node
            .loc
            .expression
            .source
            .scan(FIELDS_REGEX)
        end

        def format?(node)
          format_method?(:format, node)
        end

        def sprintf?(node)
          format_method?(:sprintf, node)
        end

        def percent?(node)
          receiver_node, method_name, *arg_nodes = *node

          method_name == :% &&
            ([:str, :dstr].include?(receiver_node.type) ||
             arg_nodes[0].type == :array)
        end

        def message(node)
          _receiver, method_name, *_args = *node
          num_args_for_format, num_expected_fields = count_matches(node)

          method_name = 'String#%' if '%' == method_name.to_s
          format(MSG, num_args_for_format, method_name, num_expected_fields)
        end
      end
    end
  end
end
