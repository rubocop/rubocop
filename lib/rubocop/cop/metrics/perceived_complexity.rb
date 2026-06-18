# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # Tries to produce a complexity score that's a measure of the
      # complexity the reader experiences when looking at a method. For that
      # reason it considers `when` nodes as something that doesn't add as much
      # complexity as an `if` or a `&&`. Except if it's one of those special
      # `case`/`when` constructs where there's no expression after `case`. Then
      # the cop treats it as an `if`/`elsif`/`elsif`... and lets all the `when`
      # nodes count. In contrast to the CyclomaticComplexity cop, this cop
      # considers `else` nodes as adding complexity.
      #
      # A `case`/`in` branch whose pattern is a simple literal (e.g. `in 1`, `in "red"`, `in 1..10`)
      # or a constant/type (e.g. `in Integer`) and has no guard is just as easy to read as a `when`
      # branch, so it is discounted the same way. Branches with structural patterns (e.g. array,
      # hash, or find patterns), bindings, alternatives, or a guard add the full complexity of
      # a decision point.
      #
      # @example
      #
      #   def example_1                   # 1
      #     if cond                       # 1
      #       case var                    # 2 (0.8 + 4 * 0.2, rounded)
      #       when 1 then func_one
      #       when 2 then func_two
      #       when 3 then func_three
      #       when 4..10 then func_other
      #       end
      #     else                          # 1
      #       do_something until a && b   # 2
      #     end                           # ===
      #   end                             # 7 complexity points
      #
      #   def example_2                   # 1
      #     case color                    # 1 (3 * 0.2, rounded)
      #     in "red" then func_red
      #     in "blue" then func_blue
      #     in "green" then func_green
      #     end                           # ===
      #   end                             # 2 complexity points
      class PerceivedComplexity < CyclomaticComplexity
        MSG = 'Perceived complexity for `%<method>s` is too high. [%<complexity>d/%<max>d]'

        COUNTED_NODES = (
          CyclomaticComplexity::COUNTED_NODES - %i[when in_pattern] + %i[case case_match]
        ).freeze

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        def complexity_score_for(node)
          case node.type
          when :case
            # If cond is nil, that means each when has an expression that evaluates to true or
            # false. It's just an alternative to if/elsif/elsif... so the when nodes count.
            nb_branches = node.when_branches.length + (node.else_branch ? 1 : 0)
            if node.condition.nil?
              nb_branches
            else
              # Otherwise, the case node gets 0.8 complexity points and each when gets 0.2.
              ((nb_branches * 0.2) + 0.8).round
            end
          when :case_match
            # Simple `in` branches are discounted like `when`, while structural patterns keep
            # the full complexity of a decision point.
            score = node.in_pattern_branches.sum { |branch| simple_in_pattern?(branch) ? 0.2 : 1 }
            score += 0.2 if node.else_branch
            score.round
          when :if
            node.else? && !node.elsif? ? 2 : 1
          else
            super
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

        def simple_in_pattern?(in_pattern_node)
          # `in_pattern_node.children[1]` is the guard (`if`/`unless`), or `nil`.
          return false unless in_pattern_node.children[1].nil?

          # A scalar literal, a literal range, or a constant/type is as easy to read as a `when`.
          pattern = in_pattern_node.pattern
          pattern.literal? || pattern.const_type?
        end
      end
    end
  end
end
