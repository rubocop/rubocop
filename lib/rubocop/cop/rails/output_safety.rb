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
          return unless looks_like_rails_html_safe?(node) ||
                        looks_like_rails_raw?(node)

          add_offense(node, :selector)
        end

        private

        def looks_like_rails_html_safe?(node)
          receiver, method_name, *args = *node

          receiver && method_name == :html_safe && args.empty? &&
            !called_from_safe_join?(node)
        end

        def looks_like_rails_raw?(node)
          receiver, method_name, *args = *node

          receiver.nil? && method_name == :raw && args.one? &&
            !called_from_safe_join?(node)
        end

        def called_from_safe_join?(node)
          from_safe_join = false
          while node.parent.is_a? RuboCop::Node
            node = node.parent
            _receiver, method_name, *_args = *node
            from_safe_join ||= (method_name == :safe_join)
          end
          from_safe_join
        end
      end
    end
  end
end
