# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of output safety calls like html_safe and
      # raw.
      #
      # @example
      #   # bad
      #   "<p>#{text}</p>".html_safe
      #
      #   # good
      #   content_tag(:p, text)
      #
      #   # bad
      #   out = ""
      #   out << content_tag(:li, "one")
      #   out << content_tag(:li, "two")
      #   out.html_safe
      #
      #   # good
      #   out = []
      #   out << content_tag(:li, "one")
      #   out << content_tag(:li, "two")
      #   safe_join(out)
      #
      class OutputSafety < Cop
        MSG = 'Tagging a string as html safe may be a security risk, ' \
              'prefer `safe_join` or other Rails tag helpers instead.'.freeze

        def on_send(node)
          ignore_node(node) if node.method?(:safe_join)

          return unless !part_of_ignored_node?(node) &&
                        (looks_like_rails_html_safe?(node) ||
                        looks_like_rails_raw?(node))

          add_offense(node, :selector)
        end

        private

        def looks_like_rails_html_safe?(node)
          node.receiver && node.method?(:html_safe) && !node.arguments?
        end

        def looks_like_rails_raw?(node)
          node.command?(:raw) && node.arguments.one?
        end
      end
    end
  end
end
