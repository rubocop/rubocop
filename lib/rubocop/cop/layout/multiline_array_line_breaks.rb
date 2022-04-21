# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop ensures that each item in a multi-line array
      # starts on a separate line.
      #
      # @example
      #
      #   # bad
      #   [
      #     a, b,
      #     c
      #   ]
      #
      #   # good
      #   [
      #     a,
      #     b,
      #     c
      #   ]
      #
      # @example AllowPercentArray: false (default)
      #
      #   # bad
      #   %w[
      #     1 2
      #     3 4
      #   ]
      #
      # @example AllowPercentArray: true
      #
      #   # good
      #   %w[
      #     1 2
      #     3 4
      #   ]
      class MultilineArrayLineBreaks < Base
        include MultilineElementLineBreaks
        extend AutoCorrector

        MSG = 'Each item in a multi-line array must start on a separate line.'

        def on_array(node)
          return if allowed_percent_array?(node)

          check_line_breaks(node, node.children)
        end

        def allowed_percent_array?(node)
          cop_config.fetch('AllowPercentArray', false) && node.percent_literal?
        end
      end
    end
  end
end
