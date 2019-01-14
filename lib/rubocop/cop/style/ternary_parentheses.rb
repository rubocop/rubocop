# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of parentheses around ternary
      # conditions. It is configurable to enforce inclusion or omission of
      # parentheses using `EnforcedStyle`. Omission is only enforced when
      # removing the parentheses won't cause a different behavior.
      #
      # @example EnforcedStyle: require_no_parentheses (default)
      #   # bad
      #   foo = (bar?) ? a : b
      #   foo = (bar.baz?) ? a : b
      #   foo = (bar && baz) ? a : b
      #
      #   # good
      #   foo = bar? ? a : b
      #   foo = bar.baz? ? a : b
      #   foo = bar && baz ? a : b
      #
      # @example EnforcedStyle: require_parentheses
      #   # bad
      #   foo = bar? ? a : b
      #   foo = bar.baz? ? a : b
      #   foo = bar && baz ? a : b
      #
      #   # good
      #   foo = (bar?) ? a : b
      #   foo = (bar.baz?) ? a : b
      #   foo = (bar && baz) ? a : b
      #
      # @example EnforcedStyle: require_parentheses_when_complex
      #   # bad
      #   foo = (bar?) ? a : b
      #   foo = (bar.baz?) ? a : b
      #   foo = bar && baz ? a : b
      #
      #   # good
      #   foo = bar? ? a : b
      #   foo = bar.baz? ? a : b
      #   foo = (bar && baz) ? a : b
      class TernaryParentheses < Cop
        include SafeAssignment
        include ConfigurableEnforcedStyle
        include SurroundingSpace

        VARIABLE_TYPES = AST::Node::VARIABLES
        NON_COMPLEX_TYPES = [*VARIABLE_TYPES, :const, :defined?, :yield].freeze

        MSG = '%<command>s parentheses for ternary conditions.'.freeze
        MSG_COMPLEX = '%<command>s parentheses for ternary expressions with' \
          ' complex conditions.'.freeze

        def on_if(node)
          return unless node.ternary? && !infinite_loop? && offense?(node)

          add_offense(node, location: node.source_range)
        end

        def autocorrect(node)
          condition = node.condition

          return nil if parenthesized?(condition) &&
                        (safe_assignment?(condition) ||
                        unsafe_autocorrect?(condition))

          if parenthesized?(condition)
            correct_parenthesized(condition)
          else
            correct_unparenthesized(condition)
          end
        end

        private

        def offense?(node)
          condition = node.condition

          if safe_assignment?(condition)
            !safe_assignment_allowed?
          else
            parens = parenthesized?(condition)
            case style
            when :require_parentheses_when_complex
              complex_condition?(condition) ? !parens : parens
            else
              require_parentheses? ? !parens : parens
            end
          end
        end

        # If the condition is parenthesized we recurse and check for any
        # complex expressions within it.
        def complex_condition?(condition)
          if condition.begin_type?
            condition.to_a.any? { |x| complex_condition?(x) }
          else
            non_complex_expression?(condition) ? false : true
          end
        end

        # Anything that is not a variable, constant, or method/.method call
        # will be counted as a complex expression.
        def non_complex_expression?(condition)
          NON_COMPLEX_TYPES.include?(condition.type) ||
            non_complex_send?(condition)
        end

        def non_complex_send?(node)
          return false unless node.send_type?

          !node.operator_method? || node.method?(:[])
        end

        def message(node)
          if require_parentheses_when_complex?
            command = parenthesized?(node.condition) ? 'Only use' : 'Use'
            format(MSG_COMPLEX, command: command)
          else
            command = require_parentheses? ? 'Use' : 'Omit'
            format(MSG, command: command)
          end
        end

        def require_parentheses?
          style == :require_parentheses
        end

        def require_parentheses_when_complex?
          style == :require_parentheses_when_complex
        end

        def redundant_parentheses_enabled?
          @config.for_cop('Style/RedundantParentheses').fetch('Enabled')
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
          method_name(child) =~ /^[a-z]/i && !child.parenthesized?
        end

        def_node_matcher :method_name, <<-PATTERN
          {($:defined? (send nil? _) ...)
           (send {_ nil?} $_ _ ...)}
        PATTERN

        def correct_parenthesized(condition)
          lambda do |corrector|
            corrector.remove(condition.loc.begin)
            corrector.remove(condition.loc.end)

            # Ruby allows no space between the question mark and parentheses.
            # If we remove the parentheses, we need to add a space or we'll
            # generate invalid code.
            unless whitespace_after?(condition)
              corrector.insert_after(condition.loc.end, ' ')
            end
          end
        end

        def correct_unparenthesized(condition)
          lambda do |corrector|
            corrector.insert_before(condition.source_range, '(')
            corrector.insert_after(condition.source_range, ')')
          end
        end

        def whitespace_after?(node)
          index = index_of_last_token(node)
          last_token = processed_source.tokens[index]
          last_token.space_after?
        end
      end
    end
  end
end
