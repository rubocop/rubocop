# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks the args passed to `fail` and `raise`.
      #
      # Exploded style (default) enforces passing the exception class and message
      # arguments separately, rather than constructing an instance of the error.
      #
      # Compact style enforces constructing an error instance.
      #
      # Both styles allow passing just a message, or an error instance when there is more
      # than one argument.
      #
      # The exploded style has an `AllowedCompactTypes` configuration
      # option that takes an `Array` of exception name Strings.
      #
      # @safety
      #   This cop is unsafe because `raise Foo` calls `Foo.exception`, not `Foo.new`.
      #
      # @example EnforcedStyle: exploded (default)
      #   # bad
      #   raise StandardError.new('message')
      #
      #   # good
      #   raise StandardError, 'message'
      #   fail 'message'
      #   raise MyCustomError
      #   raise MyCustomError.new(arg1, arg2, arg3)
      #   raise MyKwArgError.new(key1: val1, key2: val2)
      #
      #   # With `AllowedCompactTypes` set to ['MyWrappedError']
      #   raise MyWrappedError.new(obj)
      #   raise MyWrappedError.new(obj), 'message'
      #
      # @example EnforcedStyle: compact
      #   # bad
      #   raise StandardError, 'message'
      #   raise RuntimeError, arg1, arg2, arg3
      #
      #   # good
      #   raise StandardError.new('message')
      #   raise MyCustomError
      #   raise MyCustomError.new(arg1, arg2, arg3)
      #   fail 'message'
      class RaiseArgs < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        EXPLODED_MSG = 'Provide an exception class and message as arguments to `%<method>s`.'
        COMPACT_MSG = 'Provide an exception object as an argument to `%<method>s`.'
        ACCEPTABLE_ARG_TYPES = %i[
          hash forwarded_restarg splat forwarded_kwrestarg forwarded_args
        ].freeze

        RESTRICT_ON_SEND = %i[raise fail].freeze

        def on_send(node)
          return unless node.command?(:raise) || node.command?(:fail)

          case style
          when :compact
            check_compact(node)
          when :exploded
            check_exploded(node)
          end
        end

        private

        def correction_compact_to_exploded(node)
          exception_node, _new, message_node = *node.first_argument

          arguments = [exception_node, message_node].compact.map(&:source).join(', ')

          if parenthesize?(node)
            "#{node.method_name}(#{arguments})"
          else
            "#{node.method_name} #{arguments}"
          end
        end

        def correction_exploded_to_compact(node)
          exception_node, *message_nodes = *node.arguments
          return if message_nodes.size > 1

          argument = message_nodes.first.source
          exception_class = exception_class_node(exception_node).source

          if parenthesize?(node)
            "#{node.method_name}(#{exception_class}.new(#{argument}))"
          else
            "#{node.method_name} #{exception_class}.new(#{argument})"
          end
        end

        def exception_class_node(exception_node)
          use_new_method?(exception_node) ? exception_node.receiver : exception_node
        end

        def check_compact(node)
          if node.arguments.size > 1
            exception = node.first_argument
            return if exception.send_type? && exception.first_argument&.hash_type?
            return if use_new_method?(exception) && exception.arguments?

            add_offense(node, message: format(COMPACT_MSG, method: node.method_name)) do |corrector|
              correct_raise(node) { correct_to_compact(corrector, node) }
            end
          else
            correct_style_detected
          end
        end

        def correct_to_compact(corrector, node)
          if heredoc_message?(node)
            correct_heredoc_exploded_to_compact(corrector, node)
          else
            corrector.replace(node, correction_exploded_to_compact(node))
          end
        end

        def heredoc_message?(node)
          node.parenthesized? && node.arguments.size == 2 && heredoc?(node.last_argument)
        end

        def heredoc?(node)
          node.each_node(:any_str).any?(&:heredoc?)
        end

        def correct_heredoc_exploded_to_compact(corrector, node)
          exception_node, message_node = *node.arguments
          exception_class = exception_class_node(exception_node)
          corrector.replace(range_between(exception_class, message_node), '.new(')
          corrector.insert_after(message_node, ')')
        end

        def range_between(left_node, right_node)
          left_node.source_range.end.join(right_node.source_range.begin)
        end

        def check_exploded(node)
          return correct_style_detected unless node.arguments.one?

          first_arg = node.first_argument

          return if !use_new_method?(first_arg) || acceptable_exploded_args?(first_arg.arguments)

          return if allowed_non_exploded_type?(first_arg)

          add_offense(node, message: format(EXPLODED_MSG, method: node.method_name)) do |corrector|
            correct_raise(node) { correct_to_exploded(corrector, node) }
          end
        end

        def correct_to_exploded(corrector, node)
          if heredoc_new_argument?(node)
            correct_heredoc_compact_to_exploded(corrector, node)
          else
            corrector.replace(node, correction_compact_to_exploded(node))
          end
        end

        def heredoc_new_argument?(node)
          new_call = node.first_argument
          return false unless new_call.arguments.one? && heredoc?(new_call.first_argument)

          node.parenthesized? || !parenthesize?(node)
        end

        def correct_heredoc_compact_to_exploded(corrector, node)
          new_call = node.first_argument
          corrector.replace(range_between(new_call.receiver, new_call.first_argument), ', ')
          corrector.remove(new_call.loc.end) if new_call.loc.end
        end

        def correct_raise(node)
          opposite_style_detected
          return if inside_corrected_raise?(node)

          yield
          ignore_node(node)
        end

        def inside_corrected_raise?(node)
          node.each_ancestor(:send).any? { |ancestor| ignored_node?(ancestor) }
        end

        def use_new_method?(first_arg)
          first_arg.send_type? && first_arg.receiver && first_arg.method?(:new)
        end

        def acceptable_exploded_args?(args)
          # Allow code like `raise Ex.new(arg1, arg2)`.
          return true if args.size > 1

          # Disallow zero arguments.
          return false if args.empty?

          arg = args.first

          # Allow nodes that may forward more than one argument
          ACCEPTABLE_ARG_TYPES.include?(arg.type)
        end

        def allowed_non_exploded_type?(arg)
          type = arg.receiver.const_name

          Array(cop_config['AllowedCompactTypes']).include?(type)
        end

        def parenthesize?(node)
          return true if node.parenthesized?

          node.parent && requires_parens?(node.parent)
        end

        def requires_parens?(parent)
          return true if parent.operator_keyword?
          return true if parent.type?(:call, :super, :yield, :array, :pair)
          return true if parent.any_def_type? && parent.endless?

          parent.if_type? && parent.ternary?
        end
      end
    end
  end
end
