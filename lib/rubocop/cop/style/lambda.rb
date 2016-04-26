# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop (by default) checks for uses of the lambda literal syntax for
      # single line lambdas, and the method call syntax for multiline lambdas.
      # It is configurable to enforce one of the styles for both single line
      # and multiline lambdas as well.
      #
      # @example
      #
      #   # EnforcedStyle: line_count_dependent (default)
      #
      #   # bad
      #   f = lambda { |x| x }
      #   f = ->(x) do
      #         x
      #       end
      #
      #   # good
      #   f = ->(x) { x }
      #   f = lambda do |x|
      #         x
      #       end
      #
      # @example
      #
      #   # EnforcedStyle: lambda
      #
      #   # bad
      #   f = ->(x) { x }
      #   f = ->(x) do
      #         x
      #       end
      #
      #   # good
      #   f = lambda { |x| x }
      #   f = lambda do |x|
      #         x
      #       end
      #
      # @example
      #
      #   # EnforcedStyle: literal
      #
      #   # bad
      #   f = lambda { |x| x }
      #   f = lambda do |x|
      #         x
      #       end
      #
      #   # good
      #   f = ->(x) { x }
      #   f = ->(x) do
      #         x
      #       end
      class Lambda < Cop
        include ConfigurableEnforcedStyle

        LITERAL_MESSAGE = 'Use the `-> { ... }` lambda literal syntax for ' \
                          '%s lambdas.'.freeze
        METHOD_MESSAGE = 'Use the `lambda` method for %s lambdas.'.freeze

        OFFENDING_SELECTORS = {
          style: {
            lambda: { single_line: '->', multiline: '->' },
            literal: { single_line: 'lambda', multiline: 'lambda' },
            line_count_dependent: { single_line: 'lambda', multiline: '->' }
          }
        }.freeze

        TARGET = s(:send, nil, :lambda)

        def on_block(node)
          # We're looking for
          # (block
          #   (send nil :lambda)
          #   ...)
          block_method, _args, = *node

          return unless block_method == TARGET

          check(node)
        end

        private

        def check(node)
          block_method, _args, = *node

          selector = block_method.source

          if offending_selector?(node, selector)
            add_offense(node, block_method.source_range,
                        message(node, selector))
          end
        end

        def offending_selector?(node, selector)
          lines = node.multiline? ? :multiline : :single_line

          selector == OFFENDING_SELECTORS[:style][style][lines]
        end

        def message(node, selector)
          message = (selector == '->') ? METHOD_MESSAGE : LITERAL_MESSAGE

          format(message, message_line_modifier(node))
        end

        def message_line_modifier(node)
          case style
          when :line_count_dependent
            node.multiline? ? 'multiline' : 'single line'
          else
            'all'
          end
        end

        def autocorrect(node)
          block_method, _args = *node
          selector = block_method.source

          # Don't autocorrect if this would change the meaning of the code
          return if selector == '->' && arg_to_unparenthesized_call?(node)

          lambda do |corrector|
            if selector == 'lambda'
              autocorrect_method_to_literal(corrector, node)
            else
              autocorrect_literal_to_method(corrector, node)
            end
          end
        end

        def autocorrect_literal_to_method(corrector, node)
          block_method, args = *node
          # Avoid correcting to `lambdado` by inserting whitespace
          # if none exists before or after the lambda arguments.
          if needs_whitespace?(block_method, args, node)
            corrector.insert_before(node.loc.begin, ' ')
          end
          corrector.replace(block_method.source_range, 'lambda')
          corrector.remove(args.source_range) if args.source_range
          return if args.children.empty?
          arg_str = " |#{lambda_arg_string(args)}|"
          corrector.insert_after(node.loc.begin, arg_str)
        end

        def autocorrect_method_to_literal(corrector, node)
          block_method, args = *node
          corrector.replace(block_method.source_range, '->')
          return if args.children.empty?

          arg_str = "(#{lambda_arg_string(args)})"
          whitespace_and_old_args = node.loc.begin.end.join(args.loc.end)
          corrector.insert_after(block_method.source_range, arg_str)
          corrector.remove(whitespace_and_old_args)
        end

        def needs_whitespace?(block_method, args, node)
          selector_end = block_method.loc.selector.end.end_pos
          args_begin   = args.loc.begin && args.loc.begin.begin_pos
          args_end     = args.loc.end && args.loc.end.end_pos
          block_begin  = node.loc.begin.begin_pos
          (block_begin == args_end && selector_end == args_begin) ||
            (block_begin == selector_end)
        end

        def lambda_arg_string(args)
          args.children.map(&:source).join(', ')
        end

        def arg_to_unparenthesized_call?(node)
          parent = node.parent
          return false unless parent && parent.send_type?
          return false if parenthesized_call?(parent)

          index = parent.children.index { |c| c.equal?(node) }
          index >= 2
        end
      end
    end
  end
end
