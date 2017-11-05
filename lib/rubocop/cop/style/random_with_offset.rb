# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of randomly generated numbers,
      # added/subtracted with integer literals, as well as those with
      # Integer#succ and Integer#pred methods. Prefer using ranges instead,
      # as it clearly states the intentions.
      #
      # @example
      #   # bad
      #   rand(6) + 1
      #   1 + rand(6)
      #   rand(6) - 1
      #   1 - rand(6)
      #   rand(6).succ
      #   rand(6).pred
      #   Random.rand(6) + 1
      #   Kernel.rand(6) + 1
      #   rand(0..5) + 1
      #
      #   # good
      #   rand(1..6)
      #   rand(1...7)
      class RandomWithOffset < Cop
        MSG = 'Prefer ranges when generating random numbers instead of ' \
          'integers with offsets.'.freeze

        def_node_matcher :integer_op_rand?, <<-PATTERN
          (send
            int {:+ :-}
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange}))
        PATTERN

        def_node_matcher :rand_op_integer?, <<-PATTERN
          (send
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange})
            {:+ :-}
            int)
        PATTERN

        def_node_matcher :rand_modified?, <<-PATTERN
          (send
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange})
            {:succ :pred :next})
        PATTERN

        def on_send(node)
          return unless integer_op_rand?(node) ||
                        rand_op_integer?(node) ||
                        rand_modified?(node)
          add_offense(node)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            if integer_op_rand?(node)
              corrector.replace(node.source_range,
                                corrected_integer_op_rand(node))
            elsif rand_op_integer?(node)
              corrector.replace(node.source_range,
                                corrected_rand_op_integer(node))
            elsif rand_modified?(node)
              corrector.replace(node.source_range,
                                corrected_rand_modified(node))
            end
          end
        end

        def corrected_integer_op_rand(node)
          left, operator, right = *node

          offset = int_from_int_node(left)

          prefix_node, _, random_node = *right

          prefix = prefix_from_prefix_node(prefix_node)
          left_int, right_int = boundaries_from_random_node(random_node)

          if operator == :+
            "#{prefix}(#{offset + left_int}..#{offset + right_int})"
          else
            "#{prefix}(#{offset - right_int}..#{offset - left_int})"
          end
        end

        def corrected_rand_op_integer(node)
          left, operator, right = *node

          prefix_node, _, random_node = *left

          offset = int_from_int_node(right)

          prefix = prefix_from_prefix_node(prefix_node)
          left_int, right_int = boundaries_from_random_node(random_node)

          if operator == :+
            "#{prefix}(#{left_int + offset}..#{right_int + offset})"
          else
            "#{prefix}(#{left_int - offset}..#{right_int - offset})"
          end
        end

        def corrected_rand_modified(node)
          rand, method = *node
          prefix_node, _, random_node = *rand

          prefix = prefix_from_prefix_node(prefix_node)
          left_int, right_int = boundaries_from_random_node(random_node)

          if %i[succ next].include?(method)
            "#{prefix}(#{left_int + 1}..#{right_int + 1})"
          elsif method == :pred
            "#{prefix}(#{left_int - 1}..#{right_int - 1})"
          end
        end

        def prefix_from_prefix_node(node)
          if node.nil?
            'rand'
          else
            _, prefix = *node
            "#{prefix}.rand"
          end
        end

        def boundaries_from_random_node(random_node)
          children = random_node.children

          case random_node.type
          when :int
            [0, int_from_int_node(random_node) - 1]
          when :irange
            [int_from_int_node(children.first),
             int_from_int_node(children[1])]
          when :erange
            [int_from_int_node(children.first),
             int_from_int_node(children[1]) - 1]
          end
        end

        def int_from_int_node(node)
          node.children.first
        end
      end
    end
  end
end
