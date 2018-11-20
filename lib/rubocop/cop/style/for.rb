# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of the `for` keyword or `each` method. The
      # preferred alternative is set in the EnforcedStyle configuration
      # parameter. An `each` call with a block on a single line is always
      # allowed.
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
      class For < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        EACH_LENGTH = 'each'.length
        PREFER_EACH = 'Prefer `each` over `for`.'.freeze
        PREFER_FOR = 'Prefer `for` over `each`.'.freeze

        def on_for(node)
          if style == :each
            add_offense(node, message: PREFER_EACH) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def on_block(node)
          return unless suspect_enumerable?(node)

          if style == :for
            add_offense(node, message: PREFER_FOR) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          if style == :each
            ForToEachCorrector.new(node)
          else
            EachToForCorrector.new(node)
          end
        end

        private

        def suspect_enumerable?(node)
          node.multiline? &&
            node.send_node.method?(:each) && !node.send_node.arguments?
        end
      end
    end
  end
end
