# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks if empty lines around the bodies of classes match the
      # configuration.
      #
      # @example
      #
      #   class Test
      #
      #      def something
      #        ...
      #      end
      #
      #   end
      #
      class EmptyLinesAroundClassBody < Cop
        include EmptyLinesAroundBody

        KIND = 'class'.freeze

        def on_class(node)
          _name, _superclass, body = *node
          check(node, body)
        end

        def on_sclass(node)
          _obj, body = *node
          check(node, body)
        end
      end
    end
  end
end
