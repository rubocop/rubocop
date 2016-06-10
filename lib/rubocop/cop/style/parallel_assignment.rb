# encoding: utf-8
# frozen_string_literal: true

require 'tsort'

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

        MSG = 'Do not use parallel assignment.'.freeze

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

          order = find_valid_order(left_elements, right_elements)
          # For `a, b = b, a` or similar, there is no valid order
          return if order.nil?

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            left, right = *node
            left_elements = *left
            right_elements = [*right].compact
            order = find_valid_order(left_elements, right_elements)

            assignment_corrector =
              if modifier_statement?(node.parent)
                ModifierCorrector.new(node, config, order)
              elsif rescue_modifier?(node.parent)
                RescueCorrector.new(node, config, order)
              else
                GenericCorrector.new(node, config, order)
              end

            corrector.replace(assignment_corrector.correction_range,
                              assignment_corrector.correction)
          end
        end

        private

        def find_valid_order(left_elements, right_elements)
          # arrange left_elements in an order such that no corresponding right
          # element refers to a left element earlier in the sequence
          # this can be done using an algorithm called a "topological sort"
          # fortunately for us, Ruby's stdlib contains an implementation
          assignments = left_elements.zip(right_elements)

          begin
            AssignmentSorter.new(assignments).tsort
          rescue TSort::Cyclic
            nil
          end
        end

        # Helper class necessitated by silly design of TSort prior to Ruby 2.1
        # Newer versions have a better API, but that doesn't help us
        class AssignmentSorter
          include TSort
          extend RuboCop::NodePattern::Macros

          def_node_matcher :var_name, '{(casgn _ $_) (_ $_)}'
          def_node_search :uses_var?, '{({lvar ivar cvar gvar} %) (const _ %)}'
          def_node_search :matching_calls, '(send %1 %2 $...)'

          def initialize(assignments)
            @assignments = assignments
          end

          def tsort_each_node
            @assignments.each { |a| yield a }
          end

          def tsort_each_child(assignment)
            # yield all the assignments which must come after `assignment`
            # (due to dependencies on the previous value of the assigned var)
            my_lhs, _my_rhs = *assignment

            @assignments.each do |other|
              _other_lhs, other_rhs = *other
              if ((var = var_name(my_lhs)) && uses_var?(other_rhs, var)) ||
                 (my_lhs.asgn_method_call? && accesses?(other_rhs, my_lhs))
                yield other
              end
            end
          end

          # `lhs` is an assignment method call like `obj.attr=` or `ary[idx]=`.
          # Does `rhs` access the same value which is assigned by `lhs`?
          def accesses?(rhs, lhs)
            if lhs.method_name == :[]=
              matching_calls(rhs, lhs.receiver, :[]).any? do |args|
                args == lhs.method_args
              end
            else
              access_method = lhs.method_name.to_s.chop.to_sym
              matching_calls(rhs, lhs.receiver, access_method).any?
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
          node && node.rescue_type? &&
            (node.parent.nil? || !(node.parent.kwbegin_type? ||
            node.parent.ensure_type?))
        end

        # An internal class for correcting parallel assignment
        class GenericCorrector
          include AutocorrectAlignment

          attr_reader :config, :node, :correction, :correction_range

          def initialize(node, config, new_elements)
            @node = node
            @config = config
            @new_elements = new_elements
          end

          def correction
            assignment.join("\n#{offset(node)}")
          end

          def correction_range
            node.source_range
          end

          protected

          def assignment
            @new_elements.map do |lhs, rhs|
              "#{lhs.source} = #{rhs.source}"
            end
          end

          private

          def extract_sources(node)
            node.children.map(&:source)
          end

          def cop_config
            @config.for_cop('Style/ParallelAssignment')
          end
        end

        # An internal class for correcting parallel assignment
        # protected by rescue
        class RescueCorrector < GenericCorrector
          def correction
            _node, rescue_clause = *node.parent
            _, _, rescue_result = *rescue_clause

            # If the parallel assignment uses a rescue modifier and it is the
            # only contents of a method, then we want to make use of the
            # implicit begin
            if node.parent.parent && node.parent.parent.def_type?
              super + def_correction(rescue_result)
            else
              begin_correction(rescue_result)
            end
          end

          def correction_range
            node.parent.source_range
          end

          private

          def def_correction(rescue_result)
            "\nrescue" \
              "\n#{offset(node)}#{rescue_result.source}"
          end

          def begin_correction(rescue_result)
            "begin\n" \
              "#{indentation(node)}" \
              "#{assignment.join("\n#{indentation(node)}")}" \
              "\n#{offset(node)}rescue\n" \
              "#{indentation(node)}#{rescue_result.source}" \
              "\n#{offset(node)}end"
          end
        end

        # An internal class for correcting parallel assignment
        # guarded by if, unless, while, or until
        class ModifierCorrector < GenericCorrector
          def correction
            parent = node.parent

            modifier_range =
              Parser::Source::Range.new(parent.source_range.source_buffer,
                                        parent.loc.keyword.begin_pos,
                                        parent.source_range.end_pos)

            "#{modifier_range.source}\n" \
              "#{indentation(node)}" \
              "#{assignment.join("\n#{indentation(node)}")}" \
              "\n#{offset(node)}end"
          end

          def correction_range
            node.parent.source_range
          end
        end
      end
    end
  end
end
