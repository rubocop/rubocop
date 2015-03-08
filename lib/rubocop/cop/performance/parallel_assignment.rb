# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # Checks for simple usages of parallel assignment.
      # This will only complain when the number of variables
      # being assigned matched the number of assigning variables.
      #
      # @example
      #   # bad
      #   a, b, c = 1, 2, 3
      #   a, b, c = [1, 2, 3]
      #
      #   # good
      #   one, two = *foo
      #   a, b = foo()
      #
      #   a = 1
      #   b = 2
      #   c = 3
      class ParallelAssignment < Cop
        MSG = 'Do not use parallel assignment.'

        def on_masgn(node)
          left, right = *node
          left_elements = *left
          right_elements = [*right].compact # edge case for one constant

          # only complain when the number of variables matches
          return if left_elements.size != right_elements.size

          # account for edge cases using one variable with a comma
          return if left_elements.size == 1

          # allow mass assignment as the return of a method call
          return if right.block_type? || right.send_type?

          # allow mass assignment when using splat
          return if (left_elements + right_elements).any?(&:splat_type?)

          return if variable_reassignment?(left_elements, right_elements)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          left, right = *node

          lambda do |corrector|
            l_vars = extract_sources(left)
            r_vars = extract_sources(right)
            groups = l_vars.zip(r_vars)

            assignment = groups.map { |pair| pair.join(' = ') }

            space_offset = node.loc.expression.column
            corrector.replace(node.loc.expression,
                              assignment.join("\n" << ' ' * space_offset))
          end
        end

        private

        def extract_sources(node)
          node.children.map { |child| child.loc.expression.source }
        end

        def variable_reassignment?(left_elements, right_elements)
          left_elements.any? do |le|
            right_elements.any? do |re|
              re.loc.expression.is?(le.loc.expression.source)
            end
          end
        end
      end
    end
  end
end
