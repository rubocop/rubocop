# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where the `#__dir__` method can replace more
      # complex constructs to retrieve a canonicalized absolute path to the
      # current file.
      #
      # @example
      #   # bad
      #   path = File.expand_path(File.dirname(__FILE__))
      #
      #   # bad
      #   path = File.dirname(File.realpath(__FILE__))
      #
      #   # good
      #   path = __dir__
      class Dir < Base
        extend AutoCorrector

        MSG = "Use `__dir__` to get an absolute path to the current file's directory."

        def_node_matcher :dir_replacement?, <<~PATTERN
          {(send (const {nil? cbase} :File) :expand_path (send (const {nil? cbase} :File) :dirname  #file_keyword?))
           (send (const {nil? cbase} :File) :dirname     (send (const {nil? cbase} :File) :realpath #file_keyword?))}
        PATTERN

        def on_send(node)
          dir_replacement?(node) do
            add_offense(node) do |corrector|
              corrector.replace(node, '__dir__')
            end
          end
        end

        private

        def file_keyword?(node)
          node.str_type? && node.source_range.is?('__FILE__')
        end
      end
    end
  end
end
