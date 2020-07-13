# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of superfluous `.rb` extension in
      # the filename provided to `require` and `require_relative`.
      #
      # Note: If the extension is omitted, Ruby tries adding '.rb', '.so',
      #       and so on to the name until found. If the file named cannot be found,
      #       a `LoadError` will be raised.
      #       There is an edge case where `foo.so` file is loaded instead of a `LoadError`
      #       if `foo.so` file exists when `require 'foo.rb'` will be changed to `require 'foo'`,
      #       but that seems harmless.
      #
      # @example
      #   # bad
      #   require 'foo.rb'
      #   require_relative '../foo.rb'
      #
      #   # good
      #   require 'foo'
      #   require 'foo.so'
      #   require_relative '../foo'
      #   require_relative '../foo.so'
      #
      class RedundantFileExtensionInRequire < Cop
        MSG = 'Redundant `.rb` file extension detected.'

        def_node_matcher :require_call?, <<~PATTERN
          (send nil? {:require :require_relative} $str_type?)
        PATTERN

        def on_send(node)
          require_call?(node) do |name_node|
            add_offense(name_node) if name_node.value.end_with?('.rb')
          end
        end

        def autocorrect(node)
          correction = node.value.sub(/\.rb\z/, '')

          lambda do |corrector|
            corrector.replace(node, "'#{correction}'")
          end
        end
      end
    end
  end
end
