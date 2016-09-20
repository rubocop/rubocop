# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of parentheses around ternary
      # conditions. It is configurable to enforce inclusion or omission of
      # parentheses using `EnforcedStyle`.
      #
      # @example
      #
      #   EnforcedStyle: require_no_parentheses (default)
      #
      #   @bad
      #   foo = (bar?) ? a : b
      #   foo = (bar.baz) ? a : b
      #   foo = (bar && baz) ? a : b
      #
      #   @good
      #   foo = bar? ? a : b
      #   foo = bar.baz? ? a : b
      #   foo = bar && baz ? a : b
      #
      # @example
      #
      #   EnforcedStyle: require_parentheses
      #
      #   @bad
      #   foo = bar? ? a : b
      #   foo = bar.baz? ? a : b
      #   foo = bar && baz ? a : b
      #
      #   @good
      #   foo = (bar?) ? a : b
      #   foo = (bar.baz) ? a : b
      #   foo = (bar && baz) ? a : b
      class TernaryParentheses < Cop
        include IfNode
        include SafeAssignment
        include ConfigurableEnforcedStyle

        MSG = '%s parentheses for ternary conditions.'.freeze

        def on_if(node)
          return unless ternary?(node)

          add_offense(node, node.source_range, message) if offense?(node)
        end

        private

        def offense?(node)
          condition, = *node

          (require_parentheses? && !parenthesized?(condition) ||
            !require_parentheses? && parenthesized?(condition)) &&
            !(safe_assignment?(condition) && safe_assignment_allowed?) &&
            !infinite_loop?
        end

        def autocorrect(node)
          condition, = *node

          lambda do |corrector|
            if require_parentheses?
              corrector.insert_before(condition.source_range, '(')
              corrector.insert_after(condition.source_range, ')')
            else
              unless safe_assignment?(condition) ||
                     unsafe_autocorrect?(condition)
                corrector.remove(condition.loc.begin)
                corrector.remove(condition.loc.end)
              end
            end
          end
        end

        def message
          verb = require_parentheses? ? 'Use' : 'Omit'

          format(MSG, verb)
        end

        def require_parentheses?
          style == :require_parentheses
        end

        def redundant_parentheses_enabled?
          @config.for_cop('RedundantParentheses')['Enabled']
        end

        def parenthesized?(node)
          node.begin_type?
        end

        # When this cop is configured to enforce parentheses and the
        # `RedundantParentheses` cop is enabled, it will cause an infinite loop
        # as they compete to add and remove the parentheses respectively.
        def infinite_loop?
          require_parentheses? &&
            redundant_parentheses_enabled?
        end

        def unsafe_autocorrect?(condition)
          condition.children.any? do |child|
            unparenthesized_method_call?(child)
          end
        end

        def unparenthesized_method_call?(child)
          argument = method_call_argument(child)

          argument && argument !~ /^\(/
        end

        def_node_matcher :method_call_argument, <<-PATTERN
          {(:defined? $...)
           (send {(send ...) nil} _ $(send nil _)...)}
        PATTERN
      end
    end
  end
end
