# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether the multiline assignments have a newline
      # after the assignment operator.
      #
      # @example EnforcedStyle: new_line (default)
      #   # bad
      #   foo = if expression
      #     'bar'
      #   end
      #
      #   # good
      #   foo =
      #     if expression
      #       'bar'
      #     end
      #
      #   # good
      #   foo =
      #     begin
      #       compute
      #     rescue => e
      #       nil
      #     end
      #
      # @example EnforcedStyle: same_line
      #   # good
      #   foo = if expression
      #     'bar'
      #   end
      class MultilineAssignmentLayout < Cop
        include CheckAssignment
        include ConfigurableEnforcedStyle

        NEW_LINE_OFFENSE = 'Right hand side of multi-line assignment is on ' \
          'the same line as the assignment operator `=`.'.freeze

        SAME_LINE_OFFENSE = 'Right hand side of multi-line assignment is not ' \
          'on the same line as the assignment operator `=`.'.freeze

        def check_assignment(node, rhs)
          return unless rhs
          return unless supported_types.include?(rhs.type)
          return if rhs.loc.first_line == rhs.loc.last_line

          case style
          when :new_line
            check_new_line_offense(node, rhs)
          when :same_line
            check_same_line_offense(node, rhs)
          end
        end

        def check_new_line_offense(node, rhs)
          return unless node.loc.operator.line == rhs.loc.line

          add_offense(node, message: NEW_LINE_OFFENSE)
        end

        def check_same_line_offense(node, rhs)
          return unless node.loc.operator.line != rhs.loc.line

          add_offense(node, message: SAME_LINE_OFFENSE)
        end

        def autocorrect(node)
          case style
          when :new_line
            ->(corrector) { corrector.insert_after(node.loc.operator, "\n") }
          when :same_line
            range = range_between(node.loc.operator.end_pos,
                                  extract_rhs(node).source_range.begin_pos)

            ->(corrector) { corrector.replace(range, ' ') }
          end
        end

        private

        def supported_types
          @supported_types ||= cop_config['SupportedTypes'].map(&:to_sym)
        end
      end
    end
  end
end
