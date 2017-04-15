# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of the first line of the
      # right-hand-side of a multi-line assignment.
      #
      # @example
      #   # bad
      #   value =
      #   if foo
      #     'bar'
      #   end
      #
      #   # good
      #   value =
      #     if foo
      #       'bar'
      #     end
      #
      # The indentation of the remaining lines can be corrected with
      # other cops such as `IndentationConsistency` and `EndAlignment`.
      class IndentAssignment < Cop
        include CheckAssignment
        include AutocorrectAlignment

        MSG = 'Indent the first line of the right-hand-side of a ' \
              'multi-line assignment.'.freeze

        def check_assignment(node, rhs)
          return unless rhs
          return unless node.loc.operator
          return if node.loc.operator.line == rhs.loc.line

          base = display_column(node.source_range)
          check_alignment([rhs], base + configured_indentation_width)
        end
      end
    end
  end
end
