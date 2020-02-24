# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested interpolation expressions
      # which can be splitted.
      #
      # @example
      #
      #   # bad
      #   "Hello, #{user.blank? ? 'guest' : "dear #{user.name}"}"
      #   "Text: #{array_string.join("\n#{indentation_size}")}"
      #
      #   # good
      #   user_name = user.blank? ? 'guest' : "dear #{user.name}"
      #   "Hello, #{user_name}"
      #
      #   text = array_string.join("\n#{indentation_size}")
      #   "Text: #{text}"
      class RedundantNestedInterpolation < Cop
        include Interpolation

        MSG = 'Redundant nested interpolation.'

        def on_interpolation(node)
          node.each_descendant(:dstr) do |descendant_node|
            detect_nested_interpolation(descendant_node)
          end
        end

        private

        def detect_nested_interpolation(node)
          node.each_child_node(:begin) do |begin_node|
            add_offense(begin_node)
          end
        end
      end
    end
  end
end
