# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Ensures that each key in a multi-line hash
      # starts on a separate line.
      #
      # @example
      #
      #   # bad
      #   {
      #     a: 1, b: 2,
      #     c: 3
      #   }
      #
      #   # good
      #   {
      #     a: 1,
      #     b: 2,
      #     c: 3
      #   }
      class MultilineHashKeyLineBreaks < Base
        include MultilineElementLineBreaks
        extend AutoCorrector

        MSG = 'Each key in a multi-line hash must start on a separate line.'

        def on_hash(node)
          # This cop only deals with hashes wrapped by a set of curly
          # braces like {foo: 1}. That is, not a kwargs hashes.
          # Style/MultilineMethodArgumentLineBreaks handles those.
          return unless starts_with_curly_brace?(node)

          check_line_breaks(node, node.children, ignore_last: ignore_last_element?) if node.loc.begin
        end

        private

        def starts_with_curly_brace?(node)
          node.loc.begin
        end

        def ignore_last_element?
          !!cop_config['LastElementCanBeMultiline']
        end
      end
    end
  end
end
