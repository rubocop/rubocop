# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop tries to produce a complexity score that's a measure of the
      # complexity the reader experiences when looking at a method. For that
      # reason it considers `when` nodes as something that doesn't add as much
      # complexity as an `if` or a `&&`. Except if it's one of those special
      # `case`/`when` constructs where there's no expression after `case`. Then
      # the cop treats it as an `if`/`elsif`/`elsif`... and lets all the `when`
      # nodes count. In contrast to the CyclomaticComplexity cop, this cop
      # considers `else` nodes as adding complexity.
      #
      # @example
      #
      #   def my_method                   # 1
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
      class PerceivedComplexity < Cop
        include MethodComplexity

        MSG = 'Perceived complexity for %s is too high. [%d/%d]'.freeze
        COUNTED_NODES = [:if, :case, :while, :until,
                         :for, :rescue, :and, :or].freeze

        private

        def complexity_score_for(node)
          case node.type
          when :case
            expression, *whens, _else = *node
            # If cond is nil, that means each when has an expression that
            # evaluates to true or false. It's just an alternative to
            # if/elsif/elsif... so the when nodes count.
            if expression.nil?
              whens.length
            else
              # Otherwise, the case node gets 0.8 complexity points and each
              # when gets 0.2.
              (0.8 + 0.2 * whens.length).round
            end
          when :if
            node.else? && !node.elsif? ? 2 : 1
          else
            1
          end
        end
      end
    end
  end
end
