# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class MethodCallWithArgsParentheses
        # Style omit_parentheses
        # rubocop:disable Metrics/ModuleLength, Metrics/CyclomaticComplexity
        module OmitParentheses
          TRAILING_WHITESPACE_REGEX = /\s+\Z/.freeze
          OMIT_MSG = 'Omit parentheses for method calls with arguments.'
          private_constant :OMIT_MSG

          private

          def omit_parentheses(node)
            return unless node.parenthesized?
            return if inside_endless_method_def?(node)
            return if syntax_like_method_call?(node)
            return if super_call_without_arguments?(node)
            return if allowed_camel_case_method_call?(node)
            return if legitimate_call_with_parentheses?(node)
            return if allowed_string_interpolation_method_call?(node)

            add_offense(offense_range(node), message: OMIT_MSG) do |corrector|
              auto_correct(corrector, node)
            end
          end

          def auto_correct(corrector, node)
            if parentheses_at_the_end_of_multiline_call?(node)
              corrector.replace(args_begin(node), ' \\')
            else
              corrector.replace(args_begin(node), ' ')
            end
            corrector.remove(node.loc.end)
          end

          def offense_range(node)
            node.loc.begin.join(node.loc.end)
          end

          def inside_endless_method_def?(node)
            # parens are required around arguments inside an endless method
            node.each_ancestor(:def).any?(&:endless?) && node.arguments.any?
          end

          def syntax_like_method_call?(node)
            node.implicit_call? || node.operator_method?
          end

          def super_call_without_arguments?(node)
            node.super_type? && node.arguments.none?
          end

          def allowed_camel_case_method_call?(node)
            node.camel_case_method? &&
              (node.arguments.none? ||
              cop_config['AllowParenthesesInCamelCaseMethod'])
          end

          def allowed_string_interpolation_method_call?(node)
            cop_config['AllowParenthesesInStringInterpolation'] &&
              inside_string_interpolation?(node)
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
              call_in_single_line_inheritance?(node) ||
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
            parent = node.parent&.block_type? ? node.parent.parent : node.parent
            parent &&
              (logical_operator?(parent) ||
              parent.send_type? &&
              parent.arguments.any? { |argument| logical_operator?(argument) })
          end

          def call_in_optional_arguments?(node)
            node.parent &&
              (node.parent.optarg_type? || node.parent.kwoptarg_type?)
          end

          def call_in_single_line_inheritance?(node)
            node.parent&.class_type? && node.parent&.single_line?
          end

          def call_with_ambiguous_arguments?(node)
            call_with_braced_block?(node) ||
              call_as_argument_or_chain?(node) ||
              hash_literal_in_arguments?(node) ||
              node.descendants.any? do |n|
                n.forwarded_args_type? || ambigious_literal?(n) || logical_operator?(n) ||
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
              node.parent.csend_type? || node.parent.super_type? || node.parent.yield_type?)
          end

          def hash_literal_in_arguments?(node)
            node.arguments.any? do |n|
              hash_literal?(n) ||
                n.send_type? && node.descendants.any? { |descendant| hash_literal?(descendant) }
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

          def inside_string_interpolation?(node)
            node.ancestors.drop_while { |a| !a.begin_type? }.any?(&:dstr_type?)
          end
        end
        # rubocop:enable Metrics/ModuleLength, Metrics/CyclomaticComplexity
      end
    end
  end
end
