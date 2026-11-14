# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class MethodCallWithArgsParentheses
        # Style require_parentheses
        module RequireParentheses
          REQUIRE_MSG = 'Use parentheses for method calls with arguments.'
          private_constant :REQUIRE_MSG

          private

          # rubocop:disable-next Metrics/AbcSize, Metrics/CyclomaticComplexity
          def require_parentheses(node)
            return if allowed_method_name?(node.method_name)
            return if matches_allowed_pattern?(node.method_name)
            return if eligible_for_parentheses_omission?(node)
            return unless node.arguments? && !node.parenthesized?
            return if allowed_receiver?(node.receiver)

            add_offense(node, message: REQUIRE_MSG) do |corrector|
              corrector.replace(args_begin(node), '(')

              corrector.insert_after(args_end(node), ')') unless args_parenthesized?(node)
            end
          end

          def allowed_method_name?(name)
            allowed_method?(name) || matches_allowed_pattern?(name)
          end

          def eligible_for_parentheses_omission?(node)
            node.operator_method? || node.setter_method? || ignored_macro?(node)
          end

          def allowed_receiver?(receiver)
            return false unless receiver

            allowed_receivers.any? do |names|
              receiver_matches?(receiver, names, names.size - 1)
            end
          end

          # Each entry is split into names once, e.g. `Foo::Bar.baz` becomes
          # `[:Foo, :Bar, :baz]`, so that matching only needs to walk the AST.
          def allowed_receivers
            @allowed_receivers ||=
              cop_config.fetch('AllowedReceivers', []).map do |receiver|
                receiver.delete_prefix('::').split(/\.|::/).map(&:to_sym).freeze
              end.freeze
          end

          # Matches the receiver chain from its last link back to its root,
          # which must be reached exactly when the names run out.
          def receiver_matches?(node, names, index)
            return node.nil? || node.cbase_type? if index.negative?
            return false unless receiver_link_name(node) == names[index]

            receiver_matches?(receiver_link_parent(node), names, index - 1)
          end

          def receiver_link_name(node)
            case node&.type
            when :send, :csend then node.method_name
            when :const then node.short_name
            when :lvar, :ivar, :cvar, :gvar then node.children.first
            when :self then :self
            end
          end

          def receiver_link_parent(node)
            if node.call_type?
              node.receiver
            elsif node.const_type?
              node.namespace
            end
          end

          def included_macros_list
            @included_macros_list ||= cop_config.fetch('IncludedMacros', []).map(&:to_sym).freeze
          end

          def included_macro_patterns
            @included_macro_patterns ||=
              cop_config.fetch('IncludedMacroPatterns', [])
                        .map { |pattern| Regexp.new(pattern) }.freeze
          end

          def matches_included_macro_pattern?(method_name)
            included_macro_patterns.any? do |pattern|
              pattern.match?(method_name.to_s)
            end
          end

          def ignored_macro?(node)
            cop_config['IgnoreMacros'] &&
              node.macro? &&
              !included_macros_list.include?(node.method_name) &&
              !matches_included_macro_pattern?(node.method_name)
          end
        end
      end
    end
  end
end
