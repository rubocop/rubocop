# encoding: utf-8

module RuboCop
  module Cop
    module Style
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
      #   a, b = b, a
      #
      #   a = 1
      #   b = 2
      #   c = 3
      class ParallelAssignment < Cop
        include IfNode

        MSG = 'Do not use parallel assignment.'

        def on_masgn(node)
          left, right = *node
          left_elements = *left
          right_elements = [*right].compact # edge case for one constant

          # only complain when the number of variables matches
          return if left_elements.size != right_elements.size

          # account for edge cases using one variable with a comma
          return if left_elements.size == 1

          # account for edge case of Constant::CONSTANT
          return unless right.array_type?

          # allow mass assignment as the return of a method call
          return if right.block_type? || right.send_type?

          # allow mass assignment when using splat
          return if (left_elements + right_elements).any?(&:splat_type?)

          # a, b = b, a
          return if swapping_variables?(left_elements, right_elements)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            assignment_corrector =
              if modifier_statement?(node.parent)
                ModifierCorrector.new(node, config)
              elsif rescue_modifier?(node.parent)
                RescueCorrector.new(node, config)
              else
                GenericCorrector.new(node, config)
              end

            corrector.replace(assignment_corrector.correction_range,
                              assignment_corrector.correction)
          end
        end

        private

        def swapping_variables?(left_elements, right_elements)
          left_elements.any? do |le|
            right_elements.any? do |re|
              re.loc.expression.is?(le.loc.expression.source)
            end
          end
        end

        def modifier_statement?(node)
          node &&
            ((node.if_type? && modifier_if?(node)) ||
            ((node.while_type? || node.until_type?) && modifier_while?(node)))
        end

        def modifier_while?(node)
          node.loc.respond_to?(:keyword) &&
            %w(while until).include?(node.loc.keyword.source) &&
            node.loc.respond_to?(:end) && node.loc.end.nil?
        end

        def rescue_modifier?(node)
          node &&
            node.rescue_type? &&
            (node.parent.nil? || !node.parent.kwbegin_type?)
        end

        # An internal class for correcting parallel assignment
        class GenericCorrector
          include AutocorrectAlignment

          attr_reader :config, :node, :correction, :correction_range

          def initialize(node, config)
            @node = node
            @config = config
          end

          def correction
            "#{assignment.join("\n#{offset(node)}")}"
          end

          def correction_range
            node.loc.expression
          end

          protected

          def assignment
            left, right = *node
            l_vars = extract_sources(left)
            r_vars = extract_sources(right)
            groups = l_vars.zip(r_vars)
            groups.map { |pair| pair.join(' = ') }
          end

          private

          def extract_sources(node)
            node.children.map { |child| child.loc.expression.source }
          end
        end

        # An internal class for correcting parallel assignment
        # protected by rescue
        class RescueCorrector < GenericCorrector
          def correction
            _node, rescue_clause = *node.parent
            _, _, rescue_result = *rescue_clause

            "begin\n" <<
              indentation(node) << assignment.join("\n#{indentation(node)}") <<
              "\n#{offset(node)}rescue\n" <<
              indentation(node) << rescue_result.loc.expression.source <<
              "\n#{offset(node)}end"
          end

          def correction_range
            node.parent.loc.expression
          end
        end

        # An internal class for correcting parallel assignment
        # guarded by if, unless, while, or until
        class ModifierCorrector < GenericCorrector
          def correction
            parent = node.parent

            modifier_range =
              Parser::Source::Range.new(parent.loc.expression.source_buffer,
                                        parent.loc.keyword.begin_pos,
                                        parent.loc.expression.end_pos)

            "#{modifier_range.source}\n" <<
              indentation(node) << assignment.join("\n#{indentation(node)}") <<
              "\n#{offset(node)}end"
          end

          def correction_range
            node.parent.loc.expression
          end
        end
      end
    end
  end
end
