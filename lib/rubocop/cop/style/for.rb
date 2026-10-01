# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Looks for uses of the `for` keyword or `each` method. The
      # preferred alternative is set in the EnforcedStyle configuration
      # parameter. An `each` call with a block on a single line is always
      # allowed.
      #
      # NOTE: `each` is preferred in idiomatic Ruby because `for` leaks
      # its loop variable into the surrounding scope.
      #
      # @example EnforcedStyle: each (default)
      #   # bad
      #   def foo
      #     for n in [1, 2, 3] do
      #       puts n
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     [1, 2, 3].each do |n|
      #       puts n
      #     end
      #   end
      #
      # @example EnforcedStyle: for
      #   # bad
      #   def foo
      #     [1, 2, 3].each do |n|
      #       puts n
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     for n in [1, 2, 3] do
      #       puts n
      #     end
      #   end
      #
      # @safety
      #   This cop's autocorrection is unsafe because the scope of
      #   variables is different between `each` and `for`.
      #
      class For < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        EACH_LENGTH = 'each'.length
        PREFER_EACH = 'Prefer `each` over `for`.'
        PREFER_FOR = 'Prefer `for` over `each`.'
        IMPLICIT_PARAMETERS = %i[_1 _2 _3 _4 _5 _6 _7 _8 _9 it].to_set.freeze

        # `Style/RedundantBegin` removes the `begin` of a block body in the same pass,
        # leaving a `rescue` or `ensure` clause directly in the `for` body.
        def self.autocorrect_incompatible_with
          [Style::RedundantBegin]
        end

        def on_for(node)
          if style == :each
            add_offense(node, message: PREFER_EACH) do |corrector|
              opposite_style_detected
              next unless convertible_to_each?(node)

              ForToEachCorrector.new(node).call(corrector)
            end
          else
            correct_style_detected
          end
        end

        def on_block(node)
          return unless suspect_enumerable?(node)

          if style == :for
            return unless node.receiver
            return if rescue_or_ensure_body?(node) || do_end_block_in_collection?(node)

            add_offense(node, message: PREFER_FOR) do |corrector|
              EachToForCorrector.new(node).call(corrector)
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        alias on_numblock on_block
        alias on_itblock on_block

        private

        # The loop variable becomes a block parameter, which can only be a local
        # variable, and the body can't refer to an implicit block parameter
        # (`_1` or `it`) once the block has an explicit one.
        def convertible_to_each?(node)
          return false unless node.variable.each_node.all? { |n| n.type?(:lvasgn, :mlhs, :splat) }
          return true unless node.body

          node.body.each_node(:send, :lvar).none? { |ref| implicit_parameter?(ref, node) }
        end

        # Inside a numbered or `it` block, `_1` and `it` are local variables
        # rather than method calls.
        def implicit_parameter?(ref, for_node)
          return false unless implicit_parameter_reference?(ref)

          ref.each_ancestor.take_while { |ancestor| !ancestor.equal?(for_node) }
             .none?(&:any_block_type?)
        end

        def implicit_parameter_reference?(ref)
          return IMPLICIT_PARAMETERS.include?(ref.name) if ref.lvar_type?

          IMPLICIT_PARAMETERS.include?(ref.method_name) && !ref.receiver && !ref.arguments?
        end

        def suspect_enumerable?(node)
          node.multiline? && node.method?(:each) && !node.send_node.arguments?
        end

        def rescue_or_ensure_body?(node)
          node.body&.type?(:rescue, :ensure)
        end

        def do_end_block_in_collection?(node)
          node.receiver.each_node(:any_block).any?(&:keywords?)
        end
      end
    end
  end
end
