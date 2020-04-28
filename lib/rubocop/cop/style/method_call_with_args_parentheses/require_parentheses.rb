# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class MethodCallWithArgsParentheses
        # Style require_parentheses
        module RequireParentheses
          def on_send(node)
            return if ignored_method?(node.method_name)
            return if matches_ignored_pattern?(node.method_name)
            return if eligible_for_parentheses_omission?(node)
            return unless node.arguments? && !node.parenthesized?

            add_offense(node)
          end
          alias on_csend on_send
          alias on_super on_send
          alias on_yield on_send

          def autocorrect(node)
            lambda do |corrector|
              corrector.replace(args_begin(node), '(')

              unless args_parenthesized?(node)
                corrector.insert_after(args_end(node), ')')
              end
            end
          end

          def message(_node = nil)
            'Use parentheses for method calls with arguments.'
          end

          private

          def eligible_for_parentheses_omission?(node)
            node.operator_method? || node.setter_method? || ignored_macro?(node)
          end

          def included_macros_list
            cop_config.fetch('IncludedMacros', []).map(&:to_sym)
          end

          def ignored_macro?(node)
            cop_config['IgnoreMacros'] &&
              node.macro? &&
              !included_macros_list.include?(node.method_name)
          end
        end
      end
    end
  end
end
