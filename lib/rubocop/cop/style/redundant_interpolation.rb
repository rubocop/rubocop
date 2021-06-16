# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for strings that are just an interpolated expression.
      #
      # @example
      #
      #   # bad
      #   "#{@var}"
      #
      #   # good
      #   @var.to_s
      #
      #   # good if @var is already a String
      #   @var
      class RedundantInterpolation < Base
        include PercentLiteral
        extend AutoCorrector

        MSG = 'Prefer `to_s` over string interpolation.'

        def self.autocorrect_incompatible_with
          [Style::LineEndConcatenation]
        end

        def on_dstr(node)
          return unless single_interpolation?(node)

          add_offense(node) do |corrector|
            embedded_node = node.children.first

            if variable_interpolation?(embedded_node)
              autocorrect_variable_interpolation(corrector, embedded_node, node)
            elsif single_variable_interpolation?(embedded_node)
              autocorrect_single_variable_interpolation(corrector, embedded_node, node)
            else
              autocorrect_other(corrector, embedded_node, node)
            end
          end
        end

        private

        def single_interpolation?(node)
          node.children.one? &&
            interpolation?(node.children.first) &&
            !implicit_concatenation?(node) &&
            !embedded_in_percent_array?(node)
        end

        def single_variable_interpolation?(node)
          return false unless node.children.one?

          first_child = node.children.first

          variable_interpolation?(first_child) ||
            first_child.send_type? && !first_child.operator_method?
        end

        def interpolation?(node)
          variable_interpolation?(node) || node.begin_type?
        end

        def variable_interpolation?(node)
          node.variable? || node.reference?
        end

        def implicit_concatenation?(node)
          node.parent&.dstr_type?
        end

        def embedded_in_percent_array?(node)
          node.parent&.array_type? && percent_literal?(node.parent)
        end

        def autocorrect_variable_interpolation(corrector, embedded_node, node)
          replacement = "#{embedded_node.loc.expression.source}.to_s"

          corrector.replace(node, replacement)
        end

        def autocorrect_single_variable_interpolation(corrector, embedded_node, node)
          variable_loc = embedded_node.children.first.loc
          replacement = "#{variable_loc.expression.source}.to_s"

          corrector.replace(node, replacement)
        end

        def autocorrect_other(corrector, embedded_node, node)
          loc = node.loc
          embedded_loc = embedded_node.loc

          corrector.replace(loc.begin, '')
          corrector.replace(loc.end, '')
          corrector.replace(embedded_loc.begin, '(')
          corrector.replace(embedded_loc.end, ').to_s')
        end
      end
    end
  end
end
