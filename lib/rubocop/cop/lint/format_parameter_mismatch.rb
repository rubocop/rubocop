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
        MSG = "Number of arguments (%i) to `%s` doesn't match the number of " \
              'fields (%i).'.freeze
        FIELD_REGEX =
          /(%(([\s#+-0\*]*)(\d*)?(.\d+)?[bBdiouxXeEfgGaAcps]|%))/
        NAMED_FIELD_REGEX = /%\{[_a-zA-Z][_a-zA-Z]+\}/
        KERNEL = 'Kernel'.freeze
        SHOVEL = '<<'.freeze
        PERCENT = '%'.freeze
        PERCENT_PERCENT = '%%'.freeze
        STRING_TYPES = [:str, :dstr].freeze
        NAMED_INTERPOLATION = /%(?:<\w+>|\{\w+\})/

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        private

        def offending_node?(node)
          return false unless called_on_string?(node)
          return false unless method_with_format_args?(node)
          return false if named_mode?(node) || node_with_splat_args?(node)

          num_of_format_args, num_of_expected_fields = count_matches(node)

          return false if num_of_format_args == :unknown
          matched_arguments_count?(num_of_expected_fields, num_of_format_args)
        end

        def matched_arguments_count?(expected, passed)
          if passed < 0
            expected < passed.abs
          else
            expected != passed
          end
        end

        def called_on_string?(node)
          receiver_node, _method, format_string, = *node
          if receiver_node.nil? || receiver_node.const_type?
            format_string && format_string.str_type?
          else
            receiver_node.str_type?
          end
        end

        def method_with_format_args?(node)
          sprintf?(node) || format?(node) || percent?(node)
        end

        def named_mode?(node)
          receiver_node, _method_name, *args = *node

          relevant_node = if sprintf?(node) || format?(node)
                            args.first
                          elsif percent?(node)
                            receiver_node
                          end

          !relevant_node.source.scan(NAMED_FIELD_REGEX).empty?
        end

        def node_with_splat_args?(node)
          return false if percent?(node)

          _receiver_node, _method_name, *args = *node

          args.butfirst.any?(&:splat_type?)
        end

        def heredoc?(node)
          _receiver, _name, args = *node

          args.source[0, 2] == SHOVEL
        end

        def count_matches(node)
          receiver_node, _method_name, *args = *node

          if (sprintf?(node) || format?(node)) && !heredoc?(node)
            number_of_args_for_format = arguments_count(args) - 1
            number_of_expected_fields = expected_fields_count(args.first)
          elsif percent?(node) && args.first.array_type?
            number_of_expected_fields = expected_fields_count(receiver_node)
            number_of_args_for_format = arguments_count(args.first.child_nodes)
          else
            number_of_args_for_format = number_of_expected_fields = :unknown
          end

          [number_of_args_for_format, number_of_expected_fields]
        end

        def format_method?(name, node)
          receiver, method_name, *args = *node

          if receiver && receiver.const_type?
            return false unless receiver.loc.name.is?(KERNEL)
          end

          return false unless method_name == name

          args.size > 1 && args.first.str_type?
        end

        def expected_fields_count(node)
          return :unknown unless node.str_type?
          return 1 if node.source =~ NAMED_INTERPOLATION

          node
            .source
            .scan(FIELD_REGEX)
            .select { |x| x.first != PERCENT_PERCENT }
            .reduce(0) { |acc, elem| acc + (elem[2] =~ /\*/ ? 2 : 1) }
        end

        def arguments_count(args)
          if args.empty?
            0
          elsif args.last.type == :splat
            -(args.count - 1)
          else
            args.count
          end
        end

        def format?(node)
          format_method?(:format, node)
        end

        def sprintf?(node)
          format_method?(:sprintf, node)
        end

        def percent?(node)
          receiver_node, method_name, *arg_nodes = *node

          percent = method_name == :% &&
                    (STRING_TYPES.include?(receiver_node.type) ||
                     arg_nodes[0].array_type?)

          if percent && STRING_TYPES.include?(receiver_node.type)
            return false if heredoc?(node)
          end

          percent
        end

        def message(node)
          _receiver, method_name, *_args = *node
          num_args_for_format, num_expected_fields = count_matches(node)

          method_name = 'String#%' if PERCENT == method_name.to_s
          format(MSG, num_args_for_format, method_name, num_expected_fields)
        end
      end
    end
  end
end
