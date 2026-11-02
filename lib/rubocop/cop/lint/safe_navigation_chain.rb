# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # The safe navigation operator returns nil if the receiver is
      # nil. If you chain an ordinary method call after a safe
      # navigation operator, it raises NoMethodError. We should use a
      # safe navigation operator after a safe navigation operator.
      # This cop checks for the problem outlined above.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it changes the behavior of
      #   the code: `x&.foo.bar` raises `NoMethodError` when `x` or `x&.foo` is `nil`,
      #   whereas the corrected `x&.foo&.bar` returns `nil` instead. The autocorrection
      #   also assumes that extending safe navigation through the chain is intended,
      #   while removing the first `&.` may be what was intended instead.
      #
      # @example
      #
      #   # bad
      #   x&.foo.bar
      #   x&.foo + bar
      #   x&.foo[bar]
      #
      #   # good
      #   x&.foo&.bar
      #   x&.foo || bar
      class SafeNavigationChain < Base
        include NilMethods
        include RescueNode
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Do not chain ordinary method call after safe navigation operator.'
        PLUS_MINUS_METHODS = %i[+@ -@].freeze
        BODY_PARENT_TYPES = %i[
          block numblock itblock when in_pattern while until class module sclass
        ].to_set.freeze

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          {
            (send $(csend ...) $_ ...)
            (send $(any_block (csend ...) ...) $_ ...)
            (send $(begin (csend ...)) $_ ...)
          }
        PATTERN

        # rubocop:disable-next Metrics/AbcSize
        def on_send(node)
          return unless require_safe_navigation?(node)

          bad_method?(node) do |safe_nav, method|
            return if nil_methods.include?(method) || PLUS_MINUS_METHODS.include?(node.method_name)
            return if ternary_safe_navigation?(node, safe_nav)

            begin_range = node.loc.dot || safe_nav.source_range.end
            location = begin_range.join(node.source_range.end)

            add_offense(location) do |corrector|
              next if ternary_else_branch?(node, safe_nav)

              autocorrect(corrector, offense_range: location, send_node: node)
            end
          end
        end

        private

        def require_safe_navigation?(node)
          parent = node.parent
          return true unless parent&.and_type?

          parent.rhs != node || parent.lhs.receiver != parent.rhs.receiver
        end

        def ternary_safe_navigation?(node, safe_nav)
          return false unless (parent = node.parent)

          parent.if_type? && node.equal?(parent.if_branch) && parent.condition == safe_nav
        end

        def ternary_else_branch?(node, safe_nav)
          return false unless (parent = node.parent)

          parent.if_type? && node.equal?(parent.else_branch) && parent.condition == safe_nav
        end

        # @param [Parser::Source::Range] offense_range
        # @param [RuboCop::AST::SendNode] send_node
        # @return [String]
        def add_safe_navigation_operator(offense_range:, send_node:)
          source =
            if brackets?(send_node)
              format(
                '%<method_name>s(%<arguments>s)%<method_chain>s',
                arguments: send_node.arguments.map(&:source).join(', '),
                method_name: send_node.method_name,
                method_chain: send_node.source_range.end.join(send_node.source_range.end).source
              )
            else
              offense_range.source
            end
          source.prepend('.') unless source.start_with?('.')
          source.prepend('&')
        end

        # @param [RuboCop::Cop::Corrector] corrector
        # @param [Parser::Source::Range] offense_range
        # @param [RuboCop::AST::SendNode] send_node
        def autocorrect(corrector, offense_range:, send_node:)
          corrector.replace(
            offense_range,
            add_safe_navigation_operator(offense_range: offense_range, send_node: send_node)
          )

          corrector.wrap(send_node, '(', ')') if require_parentheses?(send_node)
        end

        def brackets?(send_node)
          send_node.method?(:[]) || send_node.method?(:[]=)
        end

        def require_parentheses?(send_node)
          return false if send_node.loc.dot || brackets?(send_node)

          !command_call_allowed?(send_node)
        end

        def command_call_allowed?(node)
          return true unless (parent = node.parent)
          return sole_argument?(node, parent) if argument_taking?(parent)
          return true if condition?(node, parent)

          statement?(node, parent)
        end

        def argument_taking?(node)
          return node.type?(:yield, :super, :return, :break, :next) unless node.call_type?

          !node.assignment? && !node.operator_method?
        end

        def sole_argument?(node, parent)
          return false unless parent.arguments.one?
          return false unless node.equal?(parent.first_argument)
          return false if parent.parenthesized? && parent.multiline?

          !processed_source.buffer.source.match?(/\G\s*,/, node.source_range.end_pos)
        end

        def condition?(node, parent)
          case parent.type
          when :and, :or then parent.semantic_operator?
          when :if then !parent.ternary? && node.equal?(parent.condition)
          when :while, :until, :while_post, :until_post, :case, :case_match
            node.equal?(parent.condition)
          else false
          end
        end

        def statement?(node, parent)
          return true if parent.type?(:begin, :kwbegin, :rescue, :ensure)
          return node.equal?(parent.body) if BODY_PARENT_TYPES.include?(parent.type)
          return branch?(node, parent) if parent.type?(:if, :case, :case_match)

          case parent.type
          when :def, :defs then !parent.endless?
          when :resbody then node.equal?(parent.body) && !rescue_modifier?(parent)
          else assigned_value_in_statement?(node, parent)
          end
        end

        def branch?(node, parent)
          return false if parent.if_type? && parent.ternary?

          !node.equal?(parent.condition)
        end

        def assigned_value_in_statement?(node, parent)
          return false unless parent.assignment?
          return false unless node.equal?(parent.children.last)
          return true unless (grandparent = parent.parent)

          statement?(parent, grandparent)
        end
      end
    end
  end
end
