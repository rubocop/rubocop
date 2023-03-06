# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer to use `Dir.empty?('path/to/dir')` when checking if a directory is empty.
      #
      # @example
      #   # bad
      #   Dir.entries('path/to/dir').size == 2
      #   Dir.children('path/to/dir').empty?
      #   Dir.children('path/to/dir').size == 0
      #   Dir.each_child('path/to/dir').none?
      #
      #   # good
      #   Dir.empty?('path/to/dir')
      #
      class DirEmpty < Base
        extend AutoCorrector
        extend TargetRubyVersion

        MSG = 'Use `Dir.empty?(%<arg>s)` instead.'
        RESTRICT_ON_SEND = %i[== > empty? none?].freeze

        minimum_target_ruby_version 2.4

        # @!method offensive?(node)
        def_node_matcher :offensive?, <<~PATTERN
          {
            (send (send (send $(const {nil? cbase} :Dir) :entries $_) :size) {:== :>} (int 2))
            (send (send (send $(const {nil? cbase} :Dir) :children $_) :size) {:== :>} (int 0))
            (send (send (send (send $(const {nil? cbase} :Dir) :entries $_) :size) :!) {:== :>} (int 2))
            (send (send (send (send $(const {nil? cbase} :Dir) :children $_) :size) :!) {:== :>} (int 0))
            (send (send $(const {nil? cbase} :Dir) :children $_) :empty?)
            (send (send $(const {nil? cbase} :Dir) :each_child $_) :none?)
          }
        PATTERN

        def on_send(node)
          offensive?(node) do |const_node, arg_node|
            add_offense(node, message: format(MSG, arg: arg_node.source)) do |corrector|
              bang(node)
              corrector.replace(node,
                                "#{bang(node)}#{const_node.source}.empty?(#{arg_node.source})")
            end
          end
        end

        private

        def bang(node)
          if (node.method?(:==) && node.child_nodes.first.method?(:!)) ||
             (node.method?(:>) && !node.child_nodes.first.method?(:!))
            '!'
          end
        end
      end
    end
  end
end
