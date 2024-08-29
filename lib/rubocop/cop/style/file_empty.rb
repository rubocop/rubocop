# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer to use `File.empty?('path/to/file')` when checking if a file is empty.
      #
      # @safety
      #   This cop is unsafe on `File.size`, `File.read`, and `File.binread`, because
      #   they raise an `ENOENT` exception when there is no file corresponding to the
      #   path, while `File.empty?` does not raise an exception. `File.zero?` does not,
      #   and thus is a safe offense to raise.
      #
      #
      # @example
      #   # bad
      #   File.zero?('path/to/file')
      #   File.size('path/to/file') == 0
      #   File.size('path/to/file') >= 0
      #   File.size('path/to/file').zero?
      #   File.read('path/to/file').empty?
      #   File.binread('path/to/file') == ''
      #   FileTest.zero?('path/to/file')
      #
      #   # good
      #   File.empty?('path/to/file')
      #   FileTest.empty?('path/to/file')
      #
      class FileEmpty < Base
        include MixedOffenseSafety
        extend AutoCorrector
        extend TargetRubyVersion

        MSG = 'Use `%<file_class>s.empty?(%<arg>s)` instead.'
        RESTRICT_ON_SEND = %i[>= != == zero? empty?].freeze

        minimum_target_ruby_version 2.4

        # @!method offensive?(node)
        def_node_matcher :offensive?, <<~PATTERN
          {
            (send $(const {nil? cbase} {:File :FileTest}) $:zero? $_)
            (send (send $(const {nil? cbase} {:File :FileTest}) $:size $_) {:== :>=} (int 0))
            (send (send (send $(const {nil? cbase} {:File :FileTest}) $:size $_) :!) {:== :>=} (int 0))
            (send (send $(const {nil? cbase} {:File :FileTest}) $:size $_) :zero?)
            (send (send $(const {nil? cbase} {:File :FileTest}) ${:read :binread} $_) {:!= :==} (str empty?))
            (send (send (send $(const {nil? cbase} {:File :FileTest}) ${:read :binread} $_) :!) {:!= :==} (str empty?))
            (send (send $(const {nil? cbase} {:File :FileTest}) ${:read :binread} $_) :empty?)
          }
        PATTERN

        def on_send(node)
          offensive?(node) do |const_node, method_node, arg_node|
            @offense_safety = method_node == :zero?
            replacement_node = "#{bang(node)}#{const_node.source}.empty?(#{arg_node.source})"
            add_mixed_autocorrectable_offense(node,
                                              format(MSG, file_class: const_node.source,
                                                          arg: arg_node.source),
                                              node,
                                              replacement_node)
          end
        end

        private

        def bang(node)
          if (node.method?(:==) && node.child_nodes.first.method?(:!)) ||
             (%i[>= !=].include?(node.method_name) && !node.child_nodes.first.method?(:!))
            '!'
          end
        end
      end
    end
  end
end
