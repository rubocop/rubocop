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
          (pair {(sym :target) (str "target")} {(str "_blank") (sym :_blank)})
        PATTERN

        def_node_matcher :includes_noopener?, <<-PATTERN
          (pair {(sym :rel) (str "rel")} ({str sym} #contains_noopener?))
        PATTERN

        def_node_matcher :rel_node?, <<-PATTERN
          (pair {(sym :rel) (str "rel")} (str _))
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

        def autocorrect(node)
          lambda do |corrector|
            send_node = node.parent.parent

            option_nodes = send_node.each_child_node(:hash)
            rel_node = nil
            option_nodes.map(&:children).each do |options|
              rel_node ||= options.find { |o| rel_node?(o) }
            end

            if rel_node
              append_to_rel(rel_node, corrector)
            else
              add_rel(send_node, node, corrector)
            end
          end
        end

        private

        def append_to_rel(rel_node, corrector)
          existing_rel = rel_node.children.last.value
          str_range = rel_node.children.last.loc.expression.adjust(
            begin_pos: 1,
            end_pos: -1
          )
          corrector.replace(str_range, "#{existing_rel} noopener")
        end

        def add_rel(send_node, offence_node, corrector)
          opening_quote = offence_node.children.last.source[0]
          closing_quote = opening_quote == ':' ? '' : opening_quote
          new_rel_exp = ", rel: #{opening_quote}noopener#{closing_quote}"
          range = send_node.arguments.last.source_range

          corrector.insert_after(range, new_rel_exp)
        end

        def contains_noopener?(value)
          return false unless value

          value.to_s.split(' ').include?('noopener')
        end
      end
    end
  end
end
