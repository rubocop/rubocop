# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `URI::Parser.new`
      # can be replaced by `URI::DEFAULT_PARSER`.
      #
      # @example
      #   # bad
      #   URI::Parser.new
      #
      #   # good
      #   URI::DEFAULT_PARSER
      #
      class UriDefaultParser < Cop
        MSG = 'Use `%<double_colon>sURI::DEFAULT_PARSER` instead of ' \
              '`%<double_colon>sURI::Parser.new`.'.freeze

        def_node_matcher :uri_parser_new?, <<-PATTERN
          (send
            (const
              (const ${nil? cbase} :URI) :Parser) :new)
        PATTERN

        def on_send(node)
          return unless uri_parser_new?(node) do |captured_value|
            double_colon = captured_value ? '::' : ''
            message = format(MSG, double_colon: double_colon)

            add_offense(node, message: message)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            double_colon = uri_parser_new?(node) ? '::' : ''

            corrector.replace(
              node.loc.expression, "#{double_colon}URI::DEFAULT_PARSER"
            )
          end
        end
      end
    end
  end
end
