# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a line break before the first element in a
      # multi-line hash.
      #
      # @example
      #
      #     # bad
      #     { a: 1,
      #       b: 2}
      #
      #     # good
      #     {
      #       a: 1,
      #       b: 2 }
      class FirstHashElementLineBreak < Base
        include FirstElementLineBreak
        extend AutoCorrector

        MSG = 'Add a line break before the first element of a multi-line hash.'

        def on_hash(node)
          # node.loc.begin tells us whether the hash opens with a {
          # If it doesn't, Style/FirstMethodArgumentLineBreak will handle it
          return unless node.loc.begin

          check_children_line_break(node, node.children, ignore_last: ignore_last_element?)
        end

        private

        def ignore_last_element?
          !!cop_config['LastElementCanBeMultiline']
        end
      end
    end
  end
end
