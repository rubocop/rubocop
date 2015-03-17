# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces using // or %r around regular expressions.
      #
      # @example
      #   # Bad unless AllowInnerSlashes is true.
      #   x =~ /home\//
      class RegexpLiteral < Cop
        MSG = 'Use `%r` around regular expression.'

        def on_regexp(node)
          delimiter_start = node.loc.begin.source[0]

          if delimiter_start == '/' && contains_disallowed_slash?(node)
            add_offense(node, :expression)
          end
        end

        private

        def contains_disallowed_slash?(node)
          !allow_inner_slashes? && node_body(node).include?('/')
        end

        def allow_inner_slashes?
          cop_config['AllowInnerSlashes']
        end

        def node_body(node)
          string_parts = node.children.select { |child| child.type == :str }
          string_parts.map { |s| s.loc.expression.source }.join
        end
      end
    end
  end
end
