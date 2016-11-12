# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for uses of Proc.new where Kernel#proc
      # would be more appropriate.
      class Proc < Cop
        MSG = 'Use `proc` instead of `Proc.new`.'.freeze

        def_node_matcher :proc_new?,
                         '(block $(send (const nil :Proc) :new) ...)'

        def on_block(node)
          proc_new?(node) do |block_method|
            add_offense(block_method, :expression)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.source_range, 'proc') }
        end
      end
    end
  end
end
