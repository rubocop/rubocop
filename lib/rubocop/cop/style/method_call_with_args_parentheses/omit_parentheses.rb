# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class MethodCallWithArgsParentheses
        # Style omit_parentheses
        module OmitParentheses
          TRAILING_WHITESPACE_REGEX = /\s+\Z/.freeze

          def on_send(node)
            return unless node.parenthesized?
            return if node.implicit_call?
            return if super_call_without_arguments?(node)
            return if allowed_camel_case_method_call?(node)
            return if legitimate_call_with_parentheses?(node)

            add_offense(node, location: node.loc.begin.join(node.loc.end))
          end
          alias on_csend on_send
          alias on_super on_send
          alias on_yield on_send

          def autocorrect(node)
            lambda do |corrector|
              if parentheses_at_the_end_of_multiline_call?(node)
                corrector.replace(args_begin(node), ' \\')
              else
                corrector.replace(args_begin(node), ' ')
              end
              corrector.remove(node.loc.end)
            end
          end

          def message(_node = nil)
            'Omit parentheses for method calls with arguments.'
          end

          private

          def super_call_without_arguments?(node)
            node.super_type? && node.arguments.none?
          end

          def allowed_camel_case_method_call?(node)
            node.camel_case_method? &&
              (node.arguments.none? ||
              cop_config['AllowParenthesesInCamelCaseMethod'])
          end

          def parentheses_at_the_end_of_multiline_call?(node)
            node.multiline? &&
              node.loc.begin.source_line
                  .gsub(TRAILING_WHITESPACE_REGEX, '')
                  .end_with?('(')
          end

          def legitimate_call_with_parentheses?(node)
            call_in_literals?(node) ||
              call_with_ambiguous_arguments?(node) ||
              call_in_logical_operators?(node) ||
              call_in_optional_arguments?(node) ||
              allowed_multiline_call_with_parentheses?(node) ||
              allowed_chained_call_with_parentheses?(node)
          end

          def call_in_literals?(node)
            node.parent &&
              (node.parent.pair_type? ||
              node.parent.array_type? ||
              node.parent.range_type? ||
              splat?(node.parent) ||
              ternary_if?(node.parent))
          end

          def call_in_logical_operators?(node)
            node.parent &&
              (logical_operator?(node.parent) ||
              node.parent.send_type? &&
              node.parent.arguments.any?(&method(:logical_operator?)))
          end

          def call_in_optional_arguments?(node)
            node.parent &&
              (node.parent.optarg_type? || node.parent.kwoptarg_type?)
          end

          def call_with_ambiguous_arguments?(node)
            call_with_braced_block?(node) ||
              call_as_argument_or_chain?(node) ||
              hash_literal_in_arguments?(node) ||
              node.descendants.any? do |n|
                ambigious_literal?(n) || logical_operator?(n) ||
                  call_with_braced_block?(n)
              end
          end

          def call_with_braced_block?(node)
            (node.send_type? || node.super_type?) &&
              node.block_node && node.block_node.braces?
          end

          def call_as_argument_or_chain?(node)
            node.parent &&
              (node.parent.send_type? && !assigned_before?(node.parent, node) ||
              node.parent.csend_type? || node.parent.super_type?)
          end

          def hash_literal_in_arguments?(node)
            node.arguments.any? do |n|
              hash_literal?(n) ||
                n.send_type? && node.descendants.any?(&method(:hash_literal?))
            end
          end

          def allowed_multiline_call_with_parentheses?(node)
            cop_config['AllowParenthesesInMultilineCall'] && node.multiline?
          end

          def allowed_chained_call_with_parentheses?(node)
            return false unless cop_config['AllowParenthesesInChaining']

            previous = node.descendants.first
            return false unless previous&.send_type?

            previous.parenthesized? ||
              allowed_chained_call_with_parentheses?(previous)
          end

          def ambigious_literal?(node)
            splat?(node) || ternary_if?(node) || regexp_slash_literal?(node) ||
              unary_literal?(node)
          end

          def splat?(node)
            node.splat_type? || node.kwsplat_type? || node.block_pass_type?
          end

          def ternary_if?(node)
            node.if_type? && node.ternary?
          end

          def logical_operator?(node)
            (node.and_type? || node.or_type?) && node.logical_operator?
          end

          def hash_literal?(node)
            node.hash_type? && node.braces?
          end

          def regexp_slash_literal?(node)
            node.regexp_type? && node.loc.begin.source == '/'
          end

          def unary_literal?(node)
            node.numeric_type? && node.sign? ||
              node.parent&.send_type? && node.parent&.unary_operation?
          end

          def assigned_before?(node, target)
            node.assignment? &&
              node.loc.operator.begin < target.loc.begin
          end
        end
      end
    end
  end
end
