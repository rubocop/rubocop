# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for strings that are just an interpolated expression.
      #
      # @safety
      #   Autocorrection is unsafe because when calling a destructive method to string,
      #   the resulting string may have different behavior or raise `FrozenError`.
      #
      #   [source,ruby]
      #   ----
      #   x = 'a'
      #   y = "#{x}"
      #   y << 'b'   # return 'ab'
      #   x          # return 'a'
      #   y = x.to_s
      #   y << 'b'   # return 'ab'
      #   x          # return 'ab'
      #
      #   x = 'a'.freeze
      #   y = "#{x}"
      #   y << 'b'   # return 'ab'.
      #   y = x.to_s
      #   y << 'b'   # raise `FrozenError`.
      #   ----
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
          [Style::MethodCallWithArgsParentheses]
        end

        def on_dstr(node)
          return unless single_interpolation?(node)

          embedded_node = node.children.first
          return if void_value?(embedded_node)

          add_offense(node) do |corrector|
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

        def void_value?(node)
          return false unless node
          return true if node.type?(:return, :break, :next, :redo, :retry)
          return target_ruby_version >= 3.0 if node.match_pattern_type?

          void_compound_statement?(node)
        end

        def void_compound_statement?(node)
          case node.type
          when :begin, :kwbegin then void_value?(node.children.last)
          when :if then void_value?(node.if_branch) && void_value?(node.else_branch)
          when :rescue then rescue_void_value?(node)
          when :ensure then void_value?(node.children.first) || void_value?(node.branch)
          else false
          end
        end

        def rescue_void_value?(node)
          return false unless void_value?(node.body)
          return void_value?(node.else_branch) if node.else?

          node.resbody_branches.all? { |resbody| void_value?(resbody.body) }
        end

        def single_variable_interpolation?(node)
          return false unless node.children.one?

          first_child = node.children.first
          return false unless first_child.last_line == node.last_line

          leading_lines = node.first_line...first_child.first_line
          return false if processed_source.each_comment_in_lines(leading_lines).any?

          variable_interpolation?(first_child) ||
            (first_child.send_type? && !first_child.operator_method?)
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
          replacement = "#{embedded_node.source}.to_s"

          corrector.replace(node, replacement)
        end

        # rubocop:disable-next Metrics/AbcSize
        def autocorrect_single_variable_interpolation(corrector, embedded_node, node)
          embedded_var = embedded_node.children.first
          suffix = '.to_s'

          if require_parentheses?(embedded_var)
            corrector.replace(arguments_begin_range(embedded_var), '(')
            suffix = ').to_s'
          end

          corrector.remove(node.source_range.begin.join(embedded_var.source_range.begin))
          corrector.replace(embedded_var.source_range.end.join(node.source_range.end), suffix)
        end

        def arguments_begin_range(send_node)
          first_argument_range = send_node.first_argument.source_range

          send_node.loc.selector.end.join(first_argument_range.begin)
        end

        def autocorrect_other(corrector, embedded_node, node)
          loc = node.loc
          embedded_loc = embedded_node.loc

          corrector.replace(loc.begin, '')
          corrector.replace(loc.end, '')
          corrector.replace(embedded_loc.begin, '(')
          corrector.replace(embedded_loc.end, ').to_s')
        end

        def require_parentheses?(node)
          node.send_type? && node.arguments.any? && !node.parenthesized_call?
        end
      end
    end
  end
end
