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
      class UriRegexp < Cop
        MSG = '`%<top_level>sURI.regexp%<arg>s` is obsolete and should not ' \
              'be used. Instead, use `%<top_level>sURI::DEFAULT_PARSER.' \
              'make_regexp%<arg>s`.'

        def_node_matcher :uri_regexp_with_argument?, <<~PATTERN
          (send
            (const ${nil? cbase} :URI) :regexp
            (str $_))
        PATTERN

        def_node_matcher :uri_regexp_without_argument?, <<~PATTERN
          (send
            (const ${nil? cbase} :URI) :regexp)
        PATTERN

        def on_send(node)
          uri_regexp_with_argument?(node) do |double_colon, arg|
            register_offense(
              node, top_level: double_colon ? '::' : '', arg: "('#{arg}')"
            )
          end

          uri_regexp_without_argument?(node) do |double_colon|
            register_offense(node, top_level: double_colon ? '::' : '')
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if (captured_values = uri_regexp_with_argument?(node))
            else
              captured_values = uri_regexp_without_argument?(node)
            end

            double_colon, arg = captured_values

            top_level = double_colon ? '::' : ''
            argument = arg ? "('#{arg}')" : ''

            corrector.replace(
              node.loc.expression,
              "#{top_level}URI::DEFAULT_PARSER.make_regexp#{argument}"
            )
          end
        end

        private

        def register_offense(node, top_level: '', arg: '')
          format = format(MSG, top_level: top_level, arg: arg)

          add_offense(node, location: :selector, message: format)
        end
      end
    end
  end
end
