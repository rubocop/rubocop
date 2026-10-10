# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a line break before the first element in a
      # multi-line array.
      #
      # NOTE: An array whose first element is an array literal is not checked when
      # `Layout/SpaceInsideArrayLiteralBrackets` is enabled with `EnforcedStyle: compact`,
      # since that style joins the two opening brackets.
      #
      # @example
      #
      #   # bad
      #   [ :a,
      #     :b]
      #
      #   # good
      #   [
      #     :a,
      #     :b]
      #
      #   # good
      #   [:a, :b]
      #
      # @example AllowImplicitArrayLiterals: false (default)
      #
      #   # bad
      #   a = b,
      #       c
      #
      #   # good
      #   a =
      #     b,
      #     c
      #
      # @example AllowImplicitArrayLiterals: true
      #
      #   # good
      #   a = b,
      #       c
      #
      #   a =
      #     b,
      #     c
      #
      # @example AllowMultilineFinalElement: false (default)
      #
      #   # bad
      #   [ :a, {
      #     :b => :c
      #   }]
      #
      #   # good
      #   [
      #     :a, {
      #     :b => :c
      #   }]
      #
      # @example AllowMultilineFinalElement: true
      #
      #   # good
      #   [:a, {
      #     :b => :c
      #   }]
      #
      class FirstArrayElementLineBreak < Base
        include FirstElementLineBreak
        extend AutoCorrector

        MSG = 'Add a line break before the first element of a multi-line array.'

        def on_array(node)
          return if !node.loc.begin && !assignment_on_same_line?(node)
          return if allow_implicit_array_brackets? && !node.bracketed?
          return if compact_nested_array?(node)

          check_children_line_break(node, node.children, ignore_last: ignore_last_element?)
        end

        private

        def assignment_on_same_line?(node)
          source = node.source_range.source_line[0...node.loc.column]
          /\s*=\s*$/.match?(source)
        end

        def allow_implicit_array_brackets?
          !!cop_config['AllowImplicitArrayLiterals']
        end

        def compact_nested_array?(node)
          node.square_brackets? && node.children.first&.source&.start_with?('[') &&
            compact_array_brackets_enforced?
        end

        def compact_array_brackets_enforced?
          config.cop_enabled?('Layout/SpaceInsideArrayLiteralBrackets') &&
            config.for_cop('Layout/SpaceInsideArrayLiteralBrackets')['EnforcedStyle'] == 'compact'
        end

        def ignore_last_element?
          !!cop_config['AllowMultilineFinalElement']
        end
      end
    end
  end
end
