# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for END blocks in method definitions.
      #
      # @example
      #
      #   # bad
      #
      #   def some_method
      #     END { do_something }
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     at_exit { do_something }
      #   end
      #
      # @example
      #
      #   # good
      #
      #   # outside defs
      #   END { do_something }
      class EndInMethod < Cop
        MSG = '`END` found in method definition. Use `at_exit` instead.'.freeze

        def on_postexe(node)
          inside_of_method = node.each_ancestor(:def, :defs).count.nonzero?
          add_offense(node, :keyword) if inside_of_method
        end
      end
    end
  end
end
