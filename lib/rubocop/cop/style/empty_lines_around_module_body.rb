# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks if empty lines around the bodies of modules match
      # the configuration.
      #
      # @example
      #
      #   module Test
      #
      #      def something
      #        ...
      #      end
      #
      #   end
      #
      class EmptyLinesAroundModuleBody < Cop
        include EmptyLinesAroundBody

        KIND = 'module'

        def on_module(node)
          check(node)
        end
      end
    end
  end
end
