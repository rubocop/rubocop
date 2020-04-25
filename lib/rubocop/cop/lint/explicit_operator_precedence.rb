# frozen_string_literal: true
# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Lint
      # This cop checks if binary operators of different precedents are used without explicit use of parenthesis.
      # when operators are used without parenthesis
      #
      # @example
      #
      #   # bad
      #   a && b || c
      #   a * b + c
      #   a ** b * c / d % e + f - g << h >> i & j | k ^ l
      #
      # @example
      #
      #   # good
      #   # With parenthesis, there is no ambiguity.
      #   (a && b) || c
      #   (a * b) + c
      #   (((((a**b) * c / d % e) + f - g) << h >> i) & j) | k ^ l
      class ExplicitOperatorPrecedence < Cop
        MSG = 'Operators with varied precedents used in a single statement.'

        PRECEDENCE_PRIORITY = [[:**], [:*, :/, :%], [:+, :-], [:<<, :>>], [:&], [:|, :^]]

        def on_and(node)
          add_offense(node) if node.parent.or_type?
        end

        def on_send(node)
          return unless cop_required?(node)
          add_offense(node) if multiple_precedences_used?(node)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(replacement_range(node), correction(node)) }
        end

        private

        def cop_required?(node)
          node.parent && node.parent.respond_to?(:method_name) &&
            PRECEDENCE_PRIORITY.flatten.include?(node.method_name) && PRECEDENCE_PRIORITY.flatten.include?(node.method_name)
        end

        def multiple_precedences_used?(node)
          operator_priority(node.method_name) < operator_priority(node.parent.method_name)
        end

        def operator_priority(operator)
          PRECEDENCE_PRIORITY.find_index { |operators| operators.include?(operator) }
        end

        def correction(node)
          "(#{node.source})"
        end

        def replacement_range(node)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.expression.begin_pos,
                                    node.loc.expression.end_pos)
        end
      end
    end
  end
end
