# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop identifies places where `URI.regexp`
      # can be replaced by `URI::Parser.new.make_regexp`.
      #
      # @example
      #   # bad
      #   URI.regexp("http://example.com")
      #
      #   # good
      #   URI::Parser.new.make_regexp("http://example.com")
      #
      class UriRegexp < Cop
        MSG = 'Use `URI::Parser.new.make_regexp%s` instead of `URI.regexp%s`.'
              .freeze

        def_node_matcher :uri_regexp_with_argument?, <<-PATTERN
          (send
            (const nil :URI) :regexp
            (str $_))
        PATTERN

        def_node_matcher :uri_regexp_without_argument?, <<-PATTERN
          (send
            (const nil :URI) :regexp)
        PATTERN

        def on_send(node)
          uri_regexp_with_argument?(node) do |arg|
            register_offense(node, "('#{arg}')")
          end

          uri_regexp_without_argument?(node) do
            register_offense(node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            arg = uri_regexp_with_argument?(node)

            if arg
              corrector.replace(
                node.loc.expression, "URI::Parser.new.make_regexp('#{arg}')"
              )
            else
              corrector.replace(
                node.loc.expression, 'URI::Parser.new.make_regexp'
              )
            end
          end
        end

        private

        def register_offense(node, arg = '')
          format = format(MSG, arg, arg)

          add_offense(node, :selector, format)
        end
      end
    end
  end
end
