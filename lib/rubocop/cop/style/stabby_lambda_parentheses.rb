# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for parentheses around stabby lambda arguments.
      # There are two different styles. Defaults to `require_parentheses`.
      #
      # @example EnforcedStyle: require_parentheses (default)
      #   # bad
      #   ->a,b,c { a + b + c }
      #
      #   # good
      #   ->(a,b,c) { a + b + c}
      #
      # @example EnforcedStyle: require_no_parentheses
      #   # bad
      #   ->(a,b,c) { a + b + c }
      #
      #   # good
      #   ->a,b,c { a + b + c}
      class StabbyLambdaParentheses < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG_REQUIRE = 'Wrap stabby lambda arguments with parentheses.'
        MSG_NO_REQUIRE = 'Do not wrap stabby lambda arguments with parentheses.'
        RESTRICT_ON_SEND = %i[lambda].freeze

        def on_send(node)
          return unless stabby_lambda_with_args?(node)
          return unless redundant_parentheses?(node) || missing_parentheses?(node)

          arguments = node.block_node.arguments

          add_offense(arguments) do |corrector|
            case style
            when :require_parentheses
              missing_parentheses_corrector(corrector, arguments)
            when :require_no_parentheses
              unwanted_parentheses_corrector(corrector, arguments)
            end
          end
        end

        private

        def missing_parentheses?(node)
          style == :require_parentheses && !parentheses?(node)
        end

        def redundant_parentheses?(node)
          return false unless style == :require_no_parentheses && parentheses?(node)

          arguments = node.block_node.arguments
          !arguments_require_parentheses?(arguments) && !comment_inside_parentheses?(arguments)
        end

        def arguments_require_parentheses?(arguments)
          arguments.each_descendant(:any_block, :hash).any? do |node|
            !node.hash_type? || node.braces?
          end
        end

        def comment_inside_parentheses?(arguments)
          !leading_padding(arguments).source.strip.empty? ||
            !trailing_padding(arguments).source.strip.empty?
        end

        def leading_padding(arguments)
          first_argument = arguments.children.first

          arguments.loc.begin.end.join(first_argument.source_range.begin)
        end

        def trailing_padding(arguments)
          last_argument = arguments.children.last

          last_argument.source_range.end.join(arguments.loc.end.begin)
        end

        def message(_node)
          style == :require_parentheses ? MSG_REQUIRE : MSG_NO_REQUIRE
        end

        def missing_parentheses_corrector(corrector, node)
          corrector.wrap(node, '(', ')')
        end

        def unwanted_parentheses_corrector(corrector, node)
          corrector.remove(node.loc.begin.join(leading_padding(node)))
          corrector.remove(trailing_padding(node).join(node.loc.end))
        end

        def stabby_lambda_with_args?(node)
          node.lambda_literal? && node.block_node.arguments?
        end

        def parentheses?(node)
          node.block_node.arguments.loc.begin
        end
      end
    end
  end
end
