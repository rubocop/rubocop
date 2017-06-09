# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks the args passed to `fail` and `raise`. For exploded
      # style (default), it recommends passing the exception class and message
      # to `raise`, rather than construct an instance of the error. It will
      # still allow passing just a message, or the construction of an error
      # with more than one argument.
      #
      # The exploded style works identically, but with the addition that it
      # will also suggest constructing error objects when the exception is
      # passed multiple arguments.
      #
      # @example
      #
      #   # EnforcedStyle: exploded
      #
      #   # bad
      #   raise StandardError.new("message")
      #
      #   # good
      #   raise StandardError, "message"
      #   fail "message"
      #   raise MyCustomError.new(arg1, arg2, arg3)
      #   raise MyKwArgError.new(key1: val1, key2: val2)
      #
      # @example
      #
      #   # EnforcedStyle: compact
      #
      #   # bad
      #   raise StandardError, "message"
      #   raise RuntimeError, arg1, arg2, arg3
      #
      #   # good
      #   raise StandardError.new("message")
      #   raise MyCustomError.new(arg1, arg2, arg3)
      #   fail "message"
      class RaiseArgs < Cop
        include ConfigurableEnforcedStyle

        EXPLODED_MSG = 'Provide an exception class and message ' \
          'as arguments to `%s`.'.freeze
        COMPACT_MSG = 'Provide an exception object ' \
          'as an argument to `%s`.'.freeze

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

        def autocorrect(node)
          new_exception = if style == :compact
                            correction_exploded_to_compact(node.arguments)
                          else
                            correction_compact_to_exploded(node.first_argument)
                          end
          replacement = "#{node.method_name} #{new_exception}"

          ->(corrector) { corrector.replace(node.source_range, replacement) }
        end

        def correction_compact_to_exploded(node)
          exception_node, _new, message_node = *node

          message = message_node && message_node.source

          correction = exception_node.const_name.to_s
          correction = "#{correction}, #{message}" if message

          correction
        end

        def correction_exploded_to_compact(node)
          exception_node, *message_nodes = *node

          messages = message_nodes.map(&:source).join(', ')

          "#{exception_node.const_name}.new(#{messages})"
        end

        def check_compact(node)
          if node.arguments.size > 1
            add_offense(node) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def check_exploded(node)
          return correct_style_detected unless node.arguments.one?

          first_arg = node.first_argument

          return unless first_arg.send_type? && first_arg.method?(:new)

          return if acceptable_exploded_args?(first_arg.arguments)

          add_offense(node) do
            opposite_style_detected
          end
        end

        def acceptable_exploded_args?(args)
          # Allow code like `raise Ex.new(arg1, arg2)`.
          return true if args.size > 1

          # Disallow zero arguments.
          return false if args.empty?

          arg = args.first

          # Allow code like `raise Ex.new(kw: arg)`.
          # Allow code like `raise Ex.new(*args)`.
          arg.hash_type? || arg.splat_type?
        end

        def message(node)
          if style == :compact
            format(COMPACT_MSG, node.method_name)
          else
            format(EXPLODED_MSG, node.method_name)
          end
        end
      end
    end
  end
end
