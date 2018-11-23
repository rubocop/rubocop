# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop (by default) checks for uses of the lambda literal syntax for
      # single line lambdas, and the method call syntax for multiline lambdas.
      # It is configurable to enforce one of the styles for both single line
      # and multiline lambdas as well.
      #
      # @example EnforcedStyle: line_count_dependent (default)
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
      # @example EnforcedStyle: lambda
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
      # @example EnforcedStyle: literal
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
                          '%<modifier>s lambdas.'.freeze
        METHOD_MESSAGE = 'Use the `lambda` method for %<modifier>s ' \
                         'lambdas.'.freeze

        OFFENDING_SELECTORS = {
          style: {
            lambda: { single_line: '->', multiline: '->' },
            literal: { single_line: 'lambda', multiline: 'lambda' },
            line_count_dependent: { single_line: 'lambda', multiline: '->' }
          }
        }.freeze

        def_node_matcher :lambda_node?, '(block $(send nil? :lambda) ...)'

        def on_block(node)
          return unless node.lambda?

          selector = node.send_node.source

          return unless offending_selector?(node, selector)

          add_offense(node,
                      location: node.send_node.source_range,
                      message: message(node, selector))
        end

        def autocorrect(node)
          if node.send_node.source == 'lambda'
            lambda do |corrector|
              autocorrect_method_to_literal(corrector, node)
            end
          else
            LambdaLiteralToMethodCorrector.new(node)
          end
        end

        private

        def offending_selector?(node, selector)
          lines = node.multiline? ? :multiline : :single_line

          selector == OFFENDING_SELECTORS[:style][style][lines]
        end

        def message(node, selector)
          message = selector == '->' ? METHOD_MESSAGE : LITERAL_MESSAGE

          format(message, modifier: message_line_modifier(node))
        end

        def message_line_modifier(node)
          case style
          when :line_count_dependent
            node.multiline? ? 'multiline' : 'single line'
          else
            'all'
          end
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

        def lambda_arg_string(args)
          args.children.map(&:source).join(', ')
        end
      end
    end
  end
end
