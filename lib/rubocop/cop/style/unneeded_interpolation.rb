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
      class UnneededInterpolation < Cop
        include PercentLiteral

        MSG = 'Prefer `to_s` over string interpolation.'.freeze

        def self.autocorrect_incompatible_with
          [Style::LineEndConcatenation]
        end

        def on_dstr(node)
          add_offense(node) if single_interpolation?(node)
        end

        private

        def single_interpolation?(node)
          single_child?(node) &&
            interpolation?(node.children.first) &&
            !implicit_concatenation?(node) &&
            !embedded_in_percent_array?(node)
        end

        def single_variable_interpolation?(node)
          single_child?(node) && variable_interpolation?(node.children.first)
        end

        def single_child?(node)
          node.children.one?
        end

        def interpolation?(node)
          variable_interpolation?(node) || node.begin_type?
        end

        def variable_interpolation?(node)
          node.variable? || node.reference?
        end

        def implicit_concatenation?(node)
          node.parent && node.parent.dstr_type?
        end

        def embedded_in_percent_array?(node)
          node.parent && node.parent.array_type? &&
            percent_literal?(node.parent)
        end

        def autocorrect(node)
          embedded_node = node.children.first

          if variable_interpolation?(embedded_node)
            autocorrect_variable_interpolation(embedded_node, node)
          elsif single_variable_interpolation?(embedded_node)
            autocorrect_single_variable_interpolation(embedded_node, node)
          else
            autocorrect_other(embedded_node, node)
          end
        end

        def autocorrect_variable_interpolation(embedded_node, node)
          replacement = "#{embedded_node.loc.expression.source}.to_s"
          ->(corrector) { corrector.replace(node.loc.expression, replacement) }
        end

        def autocorrect_single_variable_interpolation(embedded_node, node)
          variable_loc = embedded_node.children.first.loc
          replacement = "#{variable_loc.expression.source}.to_s"
          ->(corrector) { corrector.replace(node.loc.expression, replacement) }
        end

        def autocorrect_other(embedded_node, node)
          loc = node.loc
          embedded_loc = embedded_node.loc

          lambda do |corrector|
            corrector.replace(loc.begin, '')
            corrector.replace(loc.end, '')
            corrector.replace(embedded_loc.begin, '(')
            corrector.replace(embedded_loc.end, ').to_s')
          end
        end
      end
    end
  end
end
