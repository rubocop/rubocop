# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for formatting of assignments spanning multiple lines.
      #
      # @example
      #
      #   a = Thread.list.find_all do |t|
      #         t.alive?
      #       end.map do |t|
      #         t.object_id
      #       end
      class MultilineAssignment < Cop
        include CheckAssignment

        MSG = 'Place multi-line values on new line and indent.'

        def check_assignment(node, rhs)
          if rhs && multiline?(node.loc.expression)
            ne = node.loc.expression
            re = rhs.loc.expression

            if begin_on_same_line?(ne, re)
              if !block_application?(rhs) && !hash_literal?(rhs) &&
                  !array_literal?(rhs)
                add_offense(node, :operator)
              elsif chained_block_application?(rhs)
                add_offense(node, :operator, 'chained blocks')
              end
            elsif begin_on_same_column?(ne, re)
              add_offense(node, :operator, 'must indent')
            end
          end
        end

        private

        def multiline?(node)
          node.begin.line < node.end.line
        end

        def begin_on_same_line?(a, b)
          a.begin.line == b.begin.line
        end

        def begin_on_same_column?(a, b)
          a.begin.column == b.begin.column
        end

        def hash_literal?(rhs)
          rhs.type == :hash
        end

        def array_literal?(rhs)
          rhs.type == :array
        end

        def block_application?(rhs)
          rhs.type == :block
        end

        def chained_block_application?(rhs)
          block_application?(rhs) &&
            (first_child = first_child(rhs)) &&
            (first_grand_child = first_child(first_child)) &&
            block_application?(first_grand_child)
        end

        def first_child(node)
          node.children.first
        end
      end
    end
  end
end
