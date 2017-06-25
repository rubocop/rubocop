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
      class Dir < Cop
        extend TargetRubyVersion

        MSG = 'Use `__dir__` to get an absolute path to the current ' \
              "file's directory.".freeze

        def_node_matcher :dir_replacement?, <<-PATTERN
          {(send (const nil :File) :expand_path (send (const nil :File) :dirname  #file_keyword?))
           (send (const nil :File) :dirname     (send (const nil :File) :realpath #file_keyword?))}
        PATTERN

        minimum_target_ruby_version 2.0

        def on_send(node)
          dir_replacement?(node) do
            add_offense(node)
          end
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, '__dir__')
          end
        end

        def file_keyword?(node)
          node.str_type? && node.source_range.is?('__FILE__')
        end
      end
    end
  end
end
