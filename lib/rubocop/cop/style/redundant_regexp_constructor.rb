# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for the instantiation of a regexp using a redundant `Regexp.new` or `Regexp.compile`.
      # Autocorrect replaces it with a regexp literal which is the simplest and fastest.
      #
      # @example
      #
      #   # bad
      #   Regexp.new(/regexp/)
      #   Regexp.compile(/regexp/)
      #
      #   # good
      #   /regexp/
      #   Regexp.new('regexp')
      #   Regexp.compile('regexp')
      #
      class RedundantRegexpConstructor < Base
        extend AutoCorrector

        MSG = 'Remove the redundant `Regexp.%<method>s`.'
        RESTRICT_ON_SEND = %i[new compile].freeze

        # @!method redundant_regexp_constructor(node)
        def_node_matcher :redundant_regexp_constructor, <<~PATTERN
          (send
            (const {nil? cbase} :Regexp) {:new :compile}
            $(regexp _* (regopt _*)))
        PATTERN

        def on_send(node)
          return unless (regexp = redundant_regexp_constructor(node))

          add_offense(node, message: format(MSG, method: node.method_name)) do |corrector|
            # Reuse the inner literal's own source so its delimiters are preserved.
            # Forcing `/.../` would break patterns like `%r{foo/bar}` that contain
            # an unescaped slash.
            corrector.replace(node, regexp.source)
          end
        end
      end
    end
  end
end
