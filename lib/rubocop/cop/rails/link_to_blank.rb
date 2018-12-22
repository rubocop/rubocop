# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for calls to `link_to` that contain a
      # `target: '_blank'` but no `rel: 'noopener'`. This can be a security
      # risk as the loaded page will have control over the previous page
      # and could change its location for phishing purposes.
      #
      # @example
      #   # bad
      #   link_to 'Click here', url, target: '_blank'
      #
      #   # good
      #   link_to 'Click here', url, target: '_blank', rel: 'noopener'
      class LinkToBlank < Cop
        MSG = 'Specify a `:rel` option containing noopener.'.freeze

        def_node_matcher :blank_target?, <<-PATTERN
          (pair {(sym :target) (str "target")} (str "_blank"))
        PATTERN

        def_node_matcher :includes_noopener?, <<-PATTERN
          (pair {(sym :rel) (str "rel")} (str #contains_noopener?))
        PATTERN

        def on_send(node)
          return unless node.method?(:link_to)

          option_nodes = node.each_child_node(:hash)

          option_nodes.map(&:children).each do |options|
            blank = options.find { |o| blank_target?(o) }
            if blank && options.none? { |o| includes_noopener?(o) }
              add_offense(blank)
            end
          end
        end

        private

        def contains_noopener?(str)
          return false unless str

          str.split(' ').include?('noopener')
        end
      end
    end
  end
end
