# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of strings as keys in hashes. The use of
      # symbols is preferred instead.
      #
      # @example
      #   # bad
      #   { 'one' => 1, 'two' => 2, 'three' => 3 }
      #
      #   # good
      #   { one: 1, two: 2, three: 3 }
      class StringHashKeys < Cop
        MSG = 'Prefer symbols instead of strings as hash keys.'

        def_node_matcher :string_hash_key?, <<~PATTERN
          (pair (str _) _)
        PATTERN

        def_node_matcher :receive_environments_method?, <<~PATTERN
          {
            ^^(send (const {nil? cbase} :IO) :popen ...)
            ^^(send (const {nil? cbase} :Open3)
                {:capture2 :capture2e :capture3 :popen2 :popen2e :popen3} ...)
            ^^^(send (const {nil? cbase} :Open3)
                {:pipeline :pipeline_r :pipeline_rw :pipeline_start :pipeline_w} ...)
            ^^(send {nil? (const {nil? cbase} :Kernel)} {:spawn :system} ...)
            ^^(send _ {:gsub :gsub!} ...)
          }
        PATTERN

        def on_pair(node)
          return unless string_hash_key?(node)
          return if receive_environments_method?(node)

          add_offense(node.key)
        end

        def autocorrect(node)
          lambda do |corrector|
            symbol_content = node.str_content.to_sym.inspect
            corrector.replace(node.source_range, symbol_content)
          end
        end
      end
    end
  end
end
