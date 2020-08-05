# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop identifies places where `URI.regexp` is obsolete and should
      # not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp`.
      #
      # @example
      #   # bad
      #   URI.regexp('http://example.com')
      #
      #   # good
      #   URI::DEFAULT_PARSER.make_regexp('http://example.com')
      #
      class UriRegexp < Base
        extend AutoCorrector

        MSG = '`%<top_level>sURI.regexp%<arg>s` is obsolete and should not ' \
              'be used. Instead, use `%<top_level>sURI::DEFAULT_PARSER.' \
              'make_regexp%<arg>s`.'

        def_node_matcher :uri_regexp_with_argument?, <<~PATTERN
          (send
            (const ${nil? cbase} :URI) :regexp
            ${(str _) (array ...)})
        PATTERN

        def_node_matcher :uri_regexp_without_argument?, <<~PATTERN
          (send
            (const ${nil? cbase} :URI) :regexp)
        PATTERN

        def on_send(node)
          return unless node.method?(:regexp)

          captured_values = uri_regexp_with_argument?(node) || uri_regexp_without_argument?(node)

          double_colon, arg = captured_values

          top_level = double_colon ? '::' : ''
          argument = arg ? "(#{arg.source})" : ''

          format = format(MSG, top_level: top_level, arg: argument)

          add_offense(node.loc.selector, message: format) do |corrector|
            corrector.replace(node, "#{top_level}URI::DEFAULT_PARSER.make_regexp#{argument}")
          end
        end
      end
    end
  end
end
