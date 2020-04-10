# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of Proc.new where Kernel#proc
      # would be more appropriate.
      #
      # @example
      #   # bad
      #   p = Proc.new { |n| puts n }
      #
      #   # good
      #   p = proc { |n| puts n }
      #
      class Proc < Cop
        MSG = 'Use `proc` instead of `Proc.new`.'

        def_node_matcher :proc_new?,
                         '(block $(send (const nil? :Proc) :new) ...)'

        def on_block(node)
          proc_new?(node) do |block_method|
            add_offense(block_method)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node, 'proc') }
        end
      end
    end
  end
end
