# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicate requires in files.
      #
      # @example Duplicate requires in file
      #   require 'some_module'
      #   require "some_module"
      #
      class DuplicateRequires < Cop
        MSG = '`%s` has already been required in this file.'

        def on_send(node)
          _receiver, method, args = *node
          return unless method == :require
          arg = args.children.first # require only takes one argument
          increment_require(arg)
          check_duplicate_requires(node, arg)
        end

        private

        def check_duplicate_requires(node, arg)
          return unless duplicate_requires[arg]
          add_offense(node,
                      :expression,
                      format(MSG, arg))
        end

        def duplicate_requires
          requires.select do |_, count|
            count > 1
          end
        end

        def increment_require(arg)
          requires[arg] ||= 0
          requires[arg] += 1
        end

        def requires
          @requires ||= {}
        end
      end
    end
  end
end
